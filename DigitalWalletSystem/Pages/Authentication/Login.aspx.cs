using System;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;

namespace DigitalWalletSystem.Pages.Authentication
{
	public partial class Login : Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			// If already logged in, go straight to dashboard
			if (Session["UserID"] != null)
				Response.Redirect("~/Pages/Main/Dashboard.aspx");
		}

		protected void btnLogin_Click(object sender, EventArgs e)
		{
			if (!Page.IsValid) return;

			string accountNumber = txtAccountNumber.Text.Trim();
			string password = txtPassword.Text;
			string passwordHash = HashPassword(password);

			string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

			using (SqlConnection conn = new SqlConnection(connStr))
			{
				string sql = @"
                    SELECT u.UserID, u.FullName, u.AccountNumber, u.Username, u.IsActive
                    FROM   Users u
                    WHERE  u.AccountNumber = @AccountNumber
                    AND    u.PasswordHash  = @PasswordHash";

				using (SqlCommand cmd = new SqlCommand(sql, conn))
				{
					cmd.Parameters.AddWithValue("@AccountNumber", accountNumber);
					cmd.Parameters.AddWithValue("@PasswordHash", passwordHash);

					conn.Open();
					SqlDataReader reader = cmd.ExecuteReader();

					if (reader.Read())
					{
						// Check if account is active
						if (!Convert.ToBoolean(reader["IsActive"]))
						{
							ShowError("Your account has been deactivated. Please contact support.");
							return;
						}

						// Store session variables
						Session["UserID"] = reader["UserID"].ToString();
						Session["FullName"] = reader["FullName"].ToString();
						Session["AccountNumber"] = reader["AccountNumber"].ToString();
						Session["Username"] = reader["Username"].ToString();

						// Log the login action
						reader.Close();
						LogAudit(Convert.ToInt32(Session["UserID"]), "LOGIN", conn);

						Response.Redirect("~/Pages/Main/Dashboard.aspx");
					}
					else
					{
						ShowError("Invalid account number or password. Please try again.");
					}
				}
			}
		}

		// ── Helpers ────────────────────────────────────────────────

		private void ShowError(string message)
		{
			pnlError.Visible = true;
			lblError.Text = message;
		}

		private string HashPassword(string password)
		{
			using (SHA256 sha256 = SHA256.Create())
			{
				byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
				StringBuilder sb = new StringBuilder();
				foreach (byte b in bytes)
					sb.Append(b.ToString("x2"));
				return sb.ToString();
			}
		}

		private void LogAudit(int userID, string action, SqlConnection conn)
		{
			try
			{
				string ip = Request.UserHostAddress;
				string sql = "INSERT INTO AuditLog (UserID, Action, ActionDate, IPAddress) VALUES (@UserID, @Action, GETDATE(), @IP)";

				using (SqlCommand cmd = new SqlCommand(sql, conn))
				{
					if (conn.State != ConnectionState.Open) conn.Open();
					cmd.Parameters.AddWithValue("@UserID", userID);
					cmd.Parameters.AddWithValue("@Action", action);
					cmd.Parameters.AddWithValue("@IP", ip ?? "unknown");
					cmd.ExecuteNonQuery();
				}
			}
			catch { /* Audit log failure should not break the app */ }
		}
	}
}