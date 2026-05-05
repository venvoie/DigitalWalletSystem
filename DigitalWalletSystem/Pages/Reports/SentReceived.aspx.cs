using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using WebGrease.Activities;

namespace DigitalWalletSystem.Pages.Reports
{
	public partial class SentReceived : Page
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
			string type = ddlType.SelectedValue;
			string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

			using (SqlConnection conn = new SqlConnection(connStr))
			{
				DateTime toDateEnd = toDate.Date.AddDays(1).AddSeconds(-1);

				string sql = @"
                    SELECT
                        t.TransactionType,
                        t.TransactionDate,
                        t.Amount,
                        su.AccountNumber AS SentToAccountNo,
                        ru.AccountNumber AS ReceivedFromAccountNo
                    FROM    Transactions t
                    LEFT JOIN Users su ON su.UserID = t.SentToUserID
                    LEFT JOIN Users ru ON ru.UserID = t.ReceivedFromUserID
                    WHERE   t.UserID          = @UserID
                    AND     t.TransactionDate >= @FromDate
                    AND     t.TransactionDate <= @ToDate
                    AND     t.TransactionType IN ('S', 'R')";

				// Append type filter if not All
				if (type == "S")
					sql += " AND t.TransactionType = 'S'";
				else if (type == "R")
					sql += " AND t.TransactionType = 'R'";

				sql += " ORDER BY t.TransactionDate ASC";

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
						rptResults.Visible = false;
						lblRowCount.Text = "0";
					}
					else
					{
						pnlNoRecords.Visible = false;
						rptResults.Visible = true;
						rptResults.DataSource = dt;
						rptResults.DataBind();
						lblRowCount.Text = dt.Rows.Count.ToString();
					}

					string typeLabel = type == "All" ? "All"
									 : type == "S" ? "Sent"
									 : "Received";

					lblDateRange.Text = $"{fromDate:MMM dd, yyyy} — {toDate:MMM dd, yyyy} · {typeLabel}";
				}
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