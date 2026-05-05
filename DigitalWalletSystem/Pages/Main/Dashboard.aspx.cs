using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;

namespace DigitalWalletSystem.Pages.Main
{
	public partial class Dashboard : Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				LoadDashboard();
			}
		}

		private void LoadDashboard()
		{
			int userID = Convert.ToInt32(Session["UserID"]);
			string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

			using (SqlConnection conn = new SqlConnection(connStr))
			{
				conn.Open();

				// ── User + Wallet info ─────────────────────────────
				string sqlUser = @"
                    SELECT  u.FullName,
                            u.AccountNumber,
                            u.DateRegistered,
                            w.CurrentBalance,
                            w.TotalSentAmount
                    FROM    Users  u
                    JOIN    Wallets w ON w.UserID = u.UserID
                    WHERE   u.UserID = @UserID";

				using (SqlCommand cmd = new SqlCommand(sqlUser, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", userID);
					SqlDataReader dr = cmd.ExecuteReader();

					if (dr.Read())
					{
						lblFullName.Text = dr["FullName"].ToString();
						lblAccountNo.Text = dr["AccountNumber"].ToString();
						lblBalance.Text = Convert.ToDecimal(dr["CurrentBalance"]).ToString("N2");
						lblTotalSent.Text = Convert.ToDecimal(dr["TotalSentAmount"]).ToString("N2");
						lblDateRegistered.Text = Convert.ToDateTime(dr["DateRegistered"]).ToString("MMMM dd, yyyy");

						// Update topbar labels via master page
						SiteMaster master = (SiteMaster)this.Master;
						if (master != null)
						{
							master.SetUserInfo(
								dr["FullName"].ToString(),
								dr["AccountNumber"].ToString()
							);
						}
					}
					dr.Close();
				}

				// ── Per-type stats ─────────────────────────────────
				string sqlStats = @"
                    SELECT  TransactionType,
                            COUNT(*)        AS TxnCount,
                            SUM(Amount)     AS TotalAmount
                    FROM    Transactions
                    WHERE   UserID = @UserID
                    GROUP BY TransactionType";

				using (SqlCommand cmd = new SqlCommand(sqlStats, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", userID);
					SqlDataReader dr = cmd.ExecuteReader();

					while (dr.Read())
					{
						string type = dr["TransactionType"].ToString();
						int count = Convert.ToInt32(dr["TxnCount"]);
						decimal total = Convert.ToDecimal(dr["TotalAmount"]);

						switch (type)
						{
							case "R":
								lblTotalReceived.Text = total.ToString("N2");
								lblReceivedCount.Text = count.ToString();
								break;
							case "D":
								lblTotalDeposited.Text = total.ToString("N2");
								lblDepositCount.Text = count.ToString();
								break;
							case "W":
								lblTotalWithdrawn.Text = total.ToString("N2");
								lblWithdrawCount.Text = count.ToString();
								break;
							case "S":
								lblSentCount.Text = count.ToString();
								break;
						}
					}
					dr.Close();
				}

				// ── Recent received (notifications) — last 5 ──────
				string sqlNotifs = @"
                    SELECT  TOP 5
                            t.Amount,
                            t.TransactionDate,
                            u.FullName  AS SenderName
                    FROM    Transactions t
                    JOIN    Users u ON u.UserID = t.ReceivedFromUserID
                    WHERE   t.UserID          = @UserID
                    AND     t.TransactionType = 'R'
                    ORDER BY t.TransactionDate DESC";

				using (SqlCommand cmd = new SqlCommand(sqlNotifs, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", userID);
					SqlDataAdapter da = new SqlDataAdapter(cmd);
					DataTable dt = new DataTable();
					da.Fill(dt);

					if (dt.Rows.Count == 0)
						pnlNoNotifs.Visible = true;
					else
						rptNotifications.DataSource = dt;

					rptNotifications.DataBind();
				}

				// ── Recent transactions — last 5 ───────────────────
				string sqlTxn = @"
                    SELECT  TOP 5
                            TransactionType,
                            Amount,
                            TransactionDate
                    FROM    Transactions
                    WHERE   UserID = @UserID
                    ORDER BY TransactionDate DESC";

				using (SqlCommand cmd = new SqlCommand(sqlTxn, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", userID);
					SqlDataAdapter da = new SqlDataAdapter(cmd);
					DataTable dt = new DataTable();
					da.Fill(dt);

					if (dt.Rows.Count == 0)
						pnlNoTxn.Visible = true;
					else
						rptTransactions.DataSource = dt;

					rptTransactions.DataBind();
				}
			}
		}

		// ── Helpers used in the Repeater ItemTemplate ──────────────

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

		protected bool IsCredit(string type)
		{
			return type == "D" || type == "R";
		}
	}
}