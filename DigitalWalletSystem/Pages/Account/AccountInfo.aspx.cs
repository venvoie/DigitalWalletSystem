using System;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;

namespace DigitalWalletSystem.Pages.Account
{
	public partial class AccountInfo : Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				LoadAccountInfo();
			}
		}

		private void LoadAccountInfo()
		{
			int userID = Convert.ToInt32(Session["UserID"]);
			string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

			using (SqlConnection conn = new SqlConnection(connStr))
			{
				string sql = @"
                    SELECT  u.AccountNumber,
                            u.FullName,
                            u.Username,
                            u.Email,
                            u.DateRegistered,
                            u.IsActive,
                            w.CurrentBalance,
                            w.TotalSentAmount
                    FROM    Users   u
                    JOIN    Wallets w ON w.UserID = u.UserID
                    WHERE   u.UserID = @UserID";

				using (SqlCommand cmd = new SqlCommand(sql, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", userID);
					conn.Open();
					SqlDataReader dr = cmd.ExecuteReader();

					if (dr.Read())
					{
						lblAccountNumber.Text = dr["AccountNumber"].ToString();
						lblFullName.Text = dr["FullName"].ToString();
						lblUsername.Text = dr["Username"].ToString();
						lblEmail.Text = dr["Email"].ToString();
						lblDateRegistered.Text = Convert.ToDateTime(dr["DateRegistered"])
														.ToString("MMMM dd, yyyy hh:mm tt");
						lblBalance.Text = Convert.ToDecimal(dr["CurrentBalance"])
														.ToString("N2");
						lblTotalSent.Text = Convert.ToDecimal(dr["TotalSentAmount"])
														.ToString("N2");

						bool isActive = Convert.ToBoolean(dr["IsActive"]);
						lblStatus.Text = isActive
							? "<span class='badge-active'>Active</span>"
							: "<span class='badge-inactive'>Inactive</span>";

						// Master page handles topbar automatically from session
					}
				}
			}
		}
	}
}