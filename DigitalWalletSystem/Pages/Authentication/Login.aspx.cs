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
			if (Session["UserID"] != null)
				Response.Redirect("~/Pages/Main/Dashboard.aspx");
		}

		protected void btnLogin_Click(object sender, EventArgs e)
		{
			if (!Page.IsValid) return;

			string accountNumber = txtAccountNumber.Text.Trim();
			string passwordHash = HashPassword(txtPassword.Text);

			string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

			// look up a user matching the account number and hashed password
			string sql = @"SELECT u.UserID, u.FullName, u.AccountNumber, u.Username, u.IsActive
                           FROM   Users u
                           WHERE  u.AccountNumber = @AccountNumber
                           AND    u.PasswordHash  = @PasswordHash";

			using (var conn = new SqlConnection(connStr))
			using (var cmd = new SqlCommand(sql, conn))
			{
				cmd.Parameters.AddWithValue("@AccountNumber", accountNumber);
				cmd.Parameters.AddWithValue("@PasswordHash", passwordHash);

				conn.Open();

				using (var reader = cmd.ExecuteReader())
				{
					if (!reader.Read())
					{
						ShowError("Invalid account number or password. Please try again.");
						return;
					}

					// reject login if the account has been deactivated
					if (!Convert.ToBoolean(reader["IsActive"]))
					{
						ShowError("Your account has been deactivated. Please contact support.");
						return;
					}

					// store user details in session for use across all pages
					Session["UserID"] = reader["UserID"].ToString();
					Session["FullName"] = reader["FullName"].ToString();
					Session["AccountNumber"] = reader["AccountNumber"].ToString();
					Session["Username"] = reader["Username"].ToString();
				}

				// log the login event to the audit table
				LogAudit(Convert.ToInt32(Session["UserID"]), "LOGIN", conn);
			}

			Response.Redirect("~/Pages/Main/Dashboard.aspx");
		}

		// error alert
		private void ShowError(string message)
		{
			pnlError.Visible = true;
			lblError.Text = message;
		}

		// returns a sha256 hex hash password
		private string HashPassword(string password)
		{
			using (var sha256 = SHA256.Create())
			{
				byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
				StringBuilder sb = new StringBuilder();
				foreach (byte b in bytes) sb.Append(b.ToString("x2"));
				return sb.ToString();
			}
		}

		// inserts a row into the audit log — silently ignores failures
		private void LogAudit(int userID, string action, SqlConnection conn)
		{
			try
			{
				string sql = @"INSERT INTO AuditLog (UserID, Action, ActionDate, IPAddress)
                               VALUES (@UserID, @Action, GETDATE(), @IP)";

				using (var cmd = new SqlCommand(sql, conn))
				{
					// reopen the connection if it was closed after the reader finished
					if (conn.State != ConnectionState.Open) conn.Open();

					cmd.Parameters.AddWithValue("@UserID", userID);
					cmd.Parameters.AddWithValue("@Action", action);
					cmd.Parameters.AddWithValue("@IP", Request.UserHostAddress ?? "unknown");
					cmd.ExecuteNonQuery();
				}
			}
			catch {  }
		}
	}
}