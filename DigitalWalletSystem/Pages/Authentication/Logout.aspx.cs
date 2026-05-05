using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;

namespace DigitalWalletSystem.Pages.Authentication
{
	public partial class Logout : Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			// If not logged in, no need to show logout page — go to login
			if (Session["UserID"] == null)
				Response.Redirect("~/Pages/Authentication/Login.aspx");
		}

		protected void btnLogout_Click(object sender, EventArgs e)
		{
			// Log the logout action before clearing the session
			if (Session["UserID"] != null)
			{
				int userID = Convert.ToInt32(Session["UserID"]);
				LogAudit(userID, "LOGOUT");
			}

			// Clear all session data
			Session.Clear();
			Session.Abandon();

			// Redirect to login
			Response.Redirect("~/Pages/Authentication/Login.aspx");
		}

		protected void btnCancel_Click(object sender, EventArgs e)
		{
			// Go back to dashboard
			Response.Redirect("~/Pages/Main/Dashboard.aspx");
		}

		// ── Helpers ────────────────────────────────────────────────

		private void LogAudit(int userID, string action)
		{
			try
			{
				string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;
				using (SqlConnection conn = new SqlConnection(connStr))
				{
					conn.Open();
					string sql = @"INSERT INTO AuditLog (UserID, Action, ActionDate, IPAddress)
                                   VALUES (@UserID, @Action, GETDATE(), @IP)";
					using (SqlCommand cmd = new SqlCommand(sql, conn))
					{
						cmd.Parameters.AddWithValue("@UserID", userID);
						cmd.Parameters.AddWithValue("@Action", action);
						cmd.Parameters.AddWithValue("@IP", Request.UserHostAddress ?? "unknown");
						cmd.ExecuteNonQuery();
					}
				}
			}
			catch { /* Audit failure should not break logout */ }
		}
	}
}