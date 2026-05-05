using System;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;

namespace DigitalWalletSystem.Pages.Authentication
{
	public partial class Register : Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			// If already logged in, redirect to dashboard
			if (Session["UserID"] != null)
				Response.Redirect("~/Pages/Main/Dashboard.aspx");
		}

		protected void btnRegister_Click(object sender, EventArgs e)
		{
			if (!Page.IsValid) return;

			// ── Terms and Conditions check ─────────────────────────
			if (!chkTerms.Checked)
			{
				ShowError("You must agree to the Terms and Conditions to register.");
				return;
			}

			// ── Gather inputs ──────────────────────────────────────
			string firstName = txtFirstName.Text.Trim();
			string lastName = txtLastName.Text.Trim();
			string fullName = firstName + " " + lastName;
			string email = txtEmail.Text.Trim();
			string username = txtUsername.Text.Trim();
			string password = txtPassword.Text;
			string passHash = HashPassword(password);

			string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

			using (SqlConnection conn = new SqlConnection(connStr))
			{
				conn.Open();

				// ── Check for duplicate email ──────────────────────
				if (EmailExists(email, conn))
				{
					ShowError("That email address is already registered.");
					return;
				}

				// ── Check for duplicate username ───────────────────
				if (UsernameExists(username, conn))
				{
					ShowError("That username is already taken. Please choose another.");
					return;
				}

				// ── Generate unique account number ─────────────────
				string accountNumber = GenerateAccountNumber(conn);

				// ── Insert into Users table ────────────────────────
				string insertUser = @"
                    INSERT INTO Users
                        (AccountNumber, FullName, Username, PasswordHash, Email, DateRegistered, IsActive)
                    OUTPUT INSERTED.UserID
                    VALUES
                        (@AccountNumber, @FullName, @Username, @PasswordHash, @Email, GETDATE(), 1)";

				int newUserID;
				using (SqlCommand cmd = new SqlCommand(insertUser, conn))
				{
					cmd.Parameters.AddWithValue("@AccountNumber", accountNumber);
					cmd.Parameters.AddWithValue("@FullName", fullName);
					cmd.Parameters.AddWithValue("@Username", username);
					cmd.Parameters.AddWithValue("@PasswordHash", passHash);
					cmd.Parameters.AddWithValue("@Email", email);

					newUserID = (int)cmd.ExecuteScalar();
				}

				// ── Create wallet for the new user ─────────────────
				string insertWallet = @"
                    INSERT INTO Wallets (UserID, CurrentBalance, TotalSentAmount, LastUpdated)
                    VALUES (@UserID, 0.00, 0.00, GETDATE())";

				using (SqlCommand cmd = new SqlCommand(insertWallet, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", newUserID);
					cmd.ExecuteNonQuery();
				}

				// ── Audit log ──────────────────────────────────────
				LogAudit(newUserID, "REGISTER", conn);
			}

			// ── Show success popup then redirect via JS ────────────
			ScriptManager.RegisterStartupScript(this, GetType(),
				"successPopup", "showSuccessAndRedirect();", true);
		}

		// ── Helpers ────────────────────────────────────────────────

		private bool EmailExists(string email, SqlConnection conn)
		{
			using (SqlCommand cmd = new SqlCommand(
				"SELECT COUNT(1) FROM Users WHERE Email = @Email", conn))
			{
				cmd.Parameters.AddWithValue("@Email", email);
				return (int)cmd.ExecuteScalar() > 0;
			}
		}

		private bool UsernameExists(string username, SqlConnection conn)
		{
			using (SqlCommand cmd = new SqlCommand(
				"SELECT COUNT(1) FROM Users WHERE Username = @Username", conn))
			{
				cmd.Parameters.AddWithValue("@Username", username);
				return (int)cmd.ExecuteScalar() > 0;
			}
		}

		private string GenerateAccountNumber(SqlConnection conn)
		{
			Random rng = new Random();
			string accountNumber;
			bool exists;

			// Keep generating until we get a unique one
			do
			{
				accountNumber = rng.Next(1000000000, 2000000000).ToString();
				using (SqlCommand cmd = new SqlCommand(
					"SELECT COUNT(1) FROM Users WHERE AccountNumber = @AN", conn))
				{
					cmd.Parameters.AddWithValue("@AN", accountNumber);
					exists = (int)cmd.ExecuteScalar() > 0;
				}
			} while (exists);

			return accountNumber;
		}

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
			catch { /* Audit failure should not break registration */ }
		}
	}
}