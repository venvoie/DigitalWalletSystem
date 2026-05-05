using System;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;

namespace DigitalWalletSystem.Pages.Account
{
	public partial class ChangePassword : Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			// Master page handles topbar automatically from session
		}

		protected void btnChangePassword_Click(object sender, EventArgs e)
		{
			if (!Page.IsValid) return;

			int userID = Convert.ToInt32(Session["UserID"]);
			string currentPassword = txtCurrentPassword.Text;
			string newPassword = txtNewPassword.Text;
			string currentHash = HashPassword(currentPassword);
			string newHash = HashPassword(newPassword);

			// ── Make sure new password is different ────────────────
			if (currentHash == newHash)
			{
				ShowError("Your new password must be different from your current password.");
				return;
			}

			string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

			using (SqlConnection conn = new SqlConnection(connStr))
			{
				conn.Open();

				// ── Verify current password is correct ─────────────
				string sqlCheck = @"
                    SELECT COUNT(1)
                    FROM   Users
                    WHERE  UserID       = @UserID
                    AND    PasswordHash = @CurrentHash";

				using (SqlCommand cmd = new SqlCommand(sqlCheck, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", userID);
					cmd.Parameters.AddWithValue("@CurrentHash", currentHash);

					int match = (int)cmd.ExecuteScalar();
					if (match == 0)
					{
						ShowError("Your current password is incorrect. Please try again.");
						return;
					}
				}

				// ── Update to new password ─────────────────────────
				string sqlUpdate = @"
                    UPDATE Users
                    SET    PasswordHash = @NewHash
                    WHERE  UserID       = @UserID";

				using (SqlCommand cmd = new SqlCommand(sqlUpdate, conn))
				{
					cmd.Parameters.AddWithValue("@NewHash", newHash);
					cmd.Parameters.AddWithValue("@UserID", userID);
					cmd.ExecuteNonQuery();
				}

				// ── Audit log ──────────────────────────────────────
				LogAudit(userID, "CHANGE_PASSWORD", conn);
			}

			// Clear the fields
			txtCurrentPassword.Text = "";
			txtNewPassword.Text = "";
			txtConfirmPassword.Text = "";

			ShowSuccess("Your password has been updated successfully!");
		}

		// ── Helpers ────────────────────────────────────────────────

		private void ShowError(string message)
		{
			pnlError.Visible = true;
			pnlSuccess.Visible = false;
			lblError.Text = message;
		}

		private void ShowSuccess(string message)
		{
			pnlSuccess.Visible = true;
			pnlError.Visible = false;
			lblSuccess.Text = message;
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
			catch { /* Audit failure should not break the page */ }
		}
	}
}