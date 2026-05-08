using System;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;

namespace DigitalWalletSystem.Pages.Authentication
{
	public partial class Logout : Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			if (Session["UserID"] == null)
				Response.Redirect("~/Pages/Authentication/Login.aspx");
		}

		protected void btnLogout_Click(object sender, EventArgs e)
		{
			// log the logout event before clearing the session
			if (Session["UserID"] != null)
				LogAudit(Convert.ToInt32(Session["UserID"]), "LOGOUT");

			// clear all session data and invalidate the session
			Session.Clear();
			Session.Abandon();
			Response.Redirect("~/Pages/Authentication/Login.aspx");
		}

		protected void btnCancel_Click(object sender, EventArgs e)
		{
			Response.Redirect("~/Pages/Main/Dashboard.aspx");
		}

		// inserts a row into the audit log — silently ignores failures
		private void LogAudit(int userID, string action)
		{
			try
			{
				string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;
				string sql = @"INSERT INTO AuditLog (UserID, Action, ActionDate, IPAddress)
                                   VALUES (@UserID, @Action, GETDATE(), @IP)";

				using (var conn = new SqlConnection(connStr))
				using (var cmd = new SqlCommand(sql, conn))
				{
					conn.Open();
					cmd.Parameters.AddWithValue("@UserID", userID);
					cmd.Parameters.AddWithValue("@Action", action);
					cmd.Parameters.AddWithValue("@IP", Request.UserHostAddress ?? "unknown");
					cmd.ExecuteNonQuery();
				}
			}
			catch { }
		}
	}
}