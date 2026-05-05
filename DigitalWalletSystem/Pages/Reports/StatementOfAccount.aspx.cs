using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;

namespace DigitalWalletSystem.Pages.Reports
{
	public partial class StatementOfAccount : Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			// nothing on load — user must click List
		}

		protected void btnList_Click(object sender, EventArgs e)
		{
			if (!Page.IsValid) return;

			// ── Parse dates ────────────────────────────────────────
			DateTime fromDate, toDate;

			if (!DateTime.TryParse(txtFrom.Text, out fromDate))
			{
				ShowError("Please enter a valid From date.");
				return;
			}

			if (!DateTime.TryParse(txtTo.Text, out toDate))
			{
				ShowError("Please enter a valid To date.");
				return;
			}

			// ── Dates must not be future dates ─────────────────────
			if (fromDate.Date > DateTime.Today)
			{
				ShowError("From date must not be a future date.");
				return;
			}

			if (toDate.Date > DateTime.Today)
			{
				ShowError("To date must not be a future date.");
				return;
			}

			// ── From must be less than or equal to To ──────────────
			if (fromDate.Date > toDate.Date)
			{
				ShowError("From date must be earlier than or equal to the To date.");
				return;
			}

			pnlError.Visible = false;

			int userID = Convert.ToInt32(Session["UserID"]);
			string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

			using (SqlConnection conn = new SqlConnection(connStr))
			{
				// Include full day for toDate (up to 23:59:59)
				DateTime toDateEnd = toDate.Date.AddDays(1).AddSeconds(-1);

				string sql = @"
                    SELECT
                        t.TransactionType,
                        t.TransactionDate,
                        CASE WHEN t.TransactionType IN ('W','S') THEN t.Amount ELSE NULL END AS Debit,
                        CASE WHEN t.TransactionType IN ('D','R') THEN t.Amount ELSE NULL END AS Credit,
                        t.BalanceAfter,
                        su.AccountNumber AS SentToAccountNo,
                        ru.AccountNumber AS ReceivedFromAccountNo
                    FROM    Transactions t
                    LEFT JOIN Users su ON su.UserID = t.SentToUserID
                    LEFT JOIN Users ru ON ru.UserID = t.ReceivedFromUserID
                    WHERE   t.UserID          = @UserID
                    AND     t.TransactionDate >= @FromDate
                    AND     t.TransactionDate <= @ToDate
                    ORDER BY t.TransactionDate ASC";

				using (SqlCommand cmd = new SqlCommand(sql, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", userID);
					cmd.Parameters.AddWithValue("@FromDate", fromDate.Date);
					cmd.Parameters.AddWithValue("@ToDate", toDateEnd);

					SqlDataAdapter da = new SqlDataAdapter(cmd);
					DataTable dt = new DataTable();
					da.Fill(dt);

					pnlResults.Visible = true;

					if (dt.Rows.Count == 0)
					{
						pnlNoRecords.Visible = true;
						rptStatement.Visible = false;
						lblRowCount.Text = "0";
					}
					else
					{
						pnlNoRecords.Visible = false;
						rptStatement.Visible = true;
						rptStatement.DataSource = dt;
						rptStatement.DataBind();
						lblRowCount.Text = dt.Rows.Count.ToString();
					}

					lblDateRange.Text = $"{fromDate:MMM dd, yyyy} — {toDate:MMM dd, yyyy}";
				}
			}
		}

		// ── Helpers used in Repeater ───────────────────────────────

		protected string GetBadgeClass(string type)
		{
			switch (type)
			{
				case "D": return "deposit";
				case "W": return "withdraw";
				case "S": return "send";
				case "R": return "receive";
				default: return "";
			}
		}

		protected string GetTypeLabel(string type)
		{
			switch (type)
			{
				case "D": return "Deposit";
				case "W": return "Withdraw";
				case "S": return "Send";
				case "R": return "Receive";
				default: return type;
			}
		}

		private void ShowError(string message)
		{
			pnlError.Visible = true;
			lblError.Text = message;
			pnlResults.Visible = false;
		}
	}
}