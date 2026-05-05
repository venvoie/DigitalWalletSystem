using System;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;

namespace DigitalWalletSystem.Pages.Main
{
	public partial class SendMoney : Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				LoadCurrentBalance();
			}
		}

		private void LoadCurrentBalance()
		{
			int userID = Convert.ToInt32(Session["UserID"]);
			string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

			using (SqlConnection conn = new SqlConnection(connStr))
			{
				string sql = "SELECT CurrentBalance FROM Wallets WHERE UserID = @UserID";
				using (SqlCommand cmd = new SqlCommand(sql, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", userID);
					conn.Open();
					object result = cmd.ExecuteScalar();
					decimal balance = result != null ? Convert.ToDecimal(result) : 0;
					lblCurrentBalance.Text = balance.ToString("N2");
				}
			}
		}

		// ── STEP 1: Verify recipient account ──────────────────────
		protected void btnVerify_Click(object sender, EventArgs e)
		{
			pnlError.Visible = false;
			pnlSuccess.Visible = false;
			pnlRecipient.Visible = false;

			string recipientAccount = txtRecipientAccount.Text.Trim();

			if (string.IsNullOrEmpty(recipientAccount))
			{
				ShowError("Please enter a recipient account number.");
				return;
			}

			// Cannot send to yourself
			if (recipientAccount == Session["AccountNumber"].ToString())
			{
				ShowError("You cannot send CloudMoney to your own account.");
				return;
			}

			string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

			using (SqlConnection conn = new SqlConnection(connStr))
			{
				string sql = @"
                    SELECT UserID, FullName, AccountNumber
                    FROM   Users
                    WHERE  AccountNumber = @AccountNumber
                    AND    IsActive      = 1";

				using (SqlCommand cmd = new SqlCommand(sql, conn))
				{
					cmd.Parameters.AddWithValue("@AccountNumber", recipientAccount);
					conn.Open();
					SqlDataReader dr = cmd.ExecuteReader();

					if (dr.Read())
					{
						// Populate recipient details panel
						lblRecipientName.Text = dr["FullName"].ToString();
						lblRecipientAccountNo.Text = dr["AccountNumber"].ToString();
						hfRecipientUserID.Value = dr["UserID"].ToString();
						pnlRecipient.Visible = true;
					}
					else
					{
						ShowError("Account number not found or is inactive. Please check and try again.");
					}
				}
			}
		}

		// ── STEP 2: Send the money ─────────────────────────────────
		protected void btnSend_Click(object sender, EventArgs e)
		{
			if (!Page.IsValid) return;

			// ── Parse amount ───────────────────────────────────────
			decimal amount;
			if (!decimal.TryParse(txtAmount.Text.Trim(), out amount))
			{
				ShowError("Please enter a valid amount.");
				return;
			}

			// ── Business rules validation ──────────────────────────
			if (amount < 100)
			{
				ShowError("Minimum send amount is ₱100.00.");
				return;
			}

			if (amount > 2000)
			{
				ShowError("Maximum send amount per transaction is ₱2,000.00.");
				return;
			}

			if (amount % 100 != 0)
			{
				ShowError("Amount must be divisible by ₱100.00 (e.g. 100, 200, 500, 1000).");
				return;
			}

			// ── Recipient must be verified first ───────────────────
			if (string.IsNullOrEmpty(hfRecipientUserID.Value))
			{
				ShowError("Please verify the recipient account number first.");
				return;
			}

			int senderID = Convert.ToInt32(Session["UserID"]);
			int recipientID = Convert.ToInt32(hfRecipientUserID.Value);
			string connStr = WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

			using (SqlConnection conn = new SqlConnection(connStr))
			{
				conn.Open();

				// ── Verify sender password ─────────────────────────
				string passwordHash = HashPassword(txtPassword.Text);
				string sqlCheckPw = @"
                    SELECT COUNT(1) FROM Users
                    WHERE  UserID = @UserID AND PasswordHash = @Hash";

				using (SqlCommand cmd = new SqlCommand(sqlCheckPw, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", senderID);
					cmd.Parameters.AddWithValue("@Hash", passwordHash);
					int match = (int)cmd.ExecuteScalar();
					if (match == 0)
					{
						ShowError("Incorrect password. Transaction cancelled for security.");
						return;
					}
				}

				// ── Get sender current balance ─────────────────────
				decimal senderBalance;
				string sqlSenderBal = "SELECT CurrentBalance FROM Wallets WHERE UserID = @UserID";
				using (SqlCommand cmd = new SqlCommand(sqlSenderBal, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", senderID);
					senderBalance = Convert.ToDecimal(cmd.ExecuteScalar());
				}

				// ── Check sufficient funds ─────────────────────────
				if (amount > senderBalance)
				{
					ShowError($"Insufficient funds. Your current balance is ₱{senderBalance:N2}.");
					LoadCurrentBalance();
					return;
				}

				// ── Get recipient current balance ──────────────────
				decimal recipientBalance;
				string sqlRecipBal = "SELECT CurrentBalance FROM Wallets WHERE UserID = @UserID";
				using (SqlCommand cmd = new SqlCommand(sqlRecipBal, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", recipientID);
					recipientBalance = Convert.ToDecimal(cmd.ExecuteScalar());
				}

				decimal senderNewBalance = senderBalance - amount;
				decimal recipientNewBalance = recipientBalance + amount;

				// ── Insert SEND transaction for sender ─────────────
				string sqlSendTxn = @"
                    INSERT INTO Transactions
                        (UserID, TransactionType, Amount, BalanceAfter, SentToUserID, TransactionDate, Remarks)
                    VALUES
                        (@UserID, 'S', @Amount, @BalanceAfter, @SentToUserID, GETDATE(), 'Send CloudMoney')";

				using (SqlCommand cmd = new SqlCommand(sqlSendTxn, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", senderID);
					cmd.Parameters.AddWithValue("@Amount", amount);
					cmd.Parameters.AddWithValue("@BalanceAfter", senderNewBalance);
					cmd.Parameters.AddWithValue("@SentToUserID", recipientID);
					cmd.ExecuteNonQuery();
				}

				// ── Insert RECEIVE transaction for recipient ───────
				string sqlRecvTxn = @"
                    INSERT INTO Transactions
                        (UserID, TransactionType, Amount, BalanceAfter, ReceivedFromUserID, TransactionDate, Remarks)
                    VALUES
                        (@UserID, 'R', @Amount, @BalanceAfter, @ReceivedFromUserID, GETDATE(), 'Received CloudMoney')";

				using (SqlCommand cmd = new SqlCommand(sqlRecvTxn, conn))
				{
					cmd.Parameters.AddWithValue("@UserID", recipientID);
					cmd.Parameters.AddWithValue("@Amount", amount);
					cmd.Parameters.AddWithValue("@BalanceAfter", recipientNewBalance);
					cmd.Parameters.AddWithValue("@ReceivedFromUserID", senderID);
					cmd.ExecuteNonQuery();
				}

				// ── Update sender wallet ───────────────────────────
				string sqlUpdateSender = @"
                    UPDATE Wallets
                    SET    CurrentBalance  = @NewBalance,
                           TotalSentAmount = TotalSentAmount + @Amount,
                           LastUpdated     = GETDATE()
                    WHERE  UserID = @UserID";

				using (SqlCommand cmd = new SqlCommand(sqlUpdateSender, conn))
				{
					cmd.Parameters.AddWithValue("@NewBalance", senderNewBalance);
					cmd.Parameters.AddWithValue("@Amount", amount);
					cmd.Parameters.AddWithValue("@UserID", senderID);
					cmd.ExecuteNonQuery();
				}

				// ── Update recipient wallet ────────────────────────
				string sqlUpdateRecip = @"
                    UPDATE Wallets
                    SET    CurrentBalance = @NewBalance,
                           LastUpdated   = GETDATE()
                    WHERE  UserID = @UserID";

				using (SqlCommand cmd = new SqlCommand(sqlUpdateRecip, conn))
				{
					cmd.Parameters.AddWithValue("@NewBalance", recipientNewBalance);
					cmd.Parameters.AddWithValue("@UserID", recipientID);
					cmd.ExecuteNonQuery();
				}
			}

			// ── Reset form and show success ────────────────────────
			string recipientName = lblRecipientName.Text;
			txtAmount.Text = "";
			txtPassword.Text = "";
			txtRecipientAccount.Text = "";
			hfRecipientUserID.Value = "";
			pnlRecipient.Visible = false;
			LoadCurrentBalance();
			ShowSuccess($"Successfully sent ₱{amount:N2} to {recipientName}!");
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
	}
}