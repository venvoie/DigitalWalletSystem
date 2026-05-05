using System;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;

namespace DigitalWalletSystem.Pages.Main
{
	public partial class Withdraw : Page
	{
		private string ConnStr => WebConfigurationManager.ConnectionStrings["CloudMoneyDB"].ConnectionString;

		// current logged-in user id from session
		private int UserID => Convert.ToInt32(Session["UserID"]);

		protected void Page_Load(object sender, EventArgs e)
		{
			// only load balance on first page visit, not on postbacks
			if (!IsPostBack) LoadCurrentBalance();
		}

		// fetches and displays the user's current wallet balance
		private void LoadCurrentBalance()
		{
			using (var conn = new SqlConnection(ConnStr))
			using (var cmd = new SqlCommand("SELECT CurrentBalance FROM Wallets WHERE UserID = @UserID", conn))
			{
				cmd.Parameters.AddWithValue("@UserID", UserID);
				conn.Open();
				var result = cmd.ExecuteScalar();
				lblCurrentBalance.Text = (result != null ? Convert.ToDecimal(result) : 0m).ToString("N2");
			}
		}

		protected void btnWithdraw_Click(object sender, EventArgs e)
		{
			if (!Page.IsValid) return;

			// parse and validate the withdrawal amount
			if (!decimal.TryParse(txtAmount.Text.Trim(), out decimal amount))
			{ ShowError("Please enter a valid amount."); return; }

			// business rules: min, max, and divisibility
			if (amount < 100)
			{ ShowError("Minimum withdrawal amount is \u20B1100.00."); return; }

			if (amount > 2000)
			{ ShowError("Maximum withdrawal amount per transaction is \u20B12,000.00."); return; }

			if (amount % 100 != 0)
			{ ShowError("Amount must be divisible by \u20B1100.00 (e.g. 100, 200, 500, 1000)."); return; }

			using (var conn = new SqlConnection(ConnStr))
			{
				conn.Open();

				// get the user's current balance
				decimal currentBalance;
				using (var cmd = new SqlCommand("SELECT CurrentBalance FROM Wallets WHERE UserID = @UserID", conn))
				{
					cmd.Parameters.AddWithValue("@UserID", UserID);
					currentBalance = Convert.ToDecimal(cmd.ExecuteScalar());
				}

				// reject if insufficient funds
				if (amount > currentBalance)
				{
					ShowError($"Insufficient funds. Your current balance is \u20B1{currentBalance:N2}.");
					LoadCurrentBalance();
					return;
				}

				decimal newBalance = currentBalance - amount;

				// insert a withdrawal transaction record
				using (var cmd = new SqlCommand(@"
                    INSERT INTO Transactions (UserID, TransactionType, Amount, BalanceAfter, TransactionDate, Remarks)
                    VALUES (@UserID, 'W', @Amount, @BalanceAfter, GETDATE(), 'Withdrawal')", conn))
				{
					cmd.Parameters.AddWithValue("@UserID", UserID);
					cmd.Parameters.AddWithValue("@Amount", amount);
					cmd.Parameters.AddWithValue("@BalanceAfter", newBalance);
					cmd.ExecuteNonQuery();
				}

				// update the wallet balance in the database
				using (var cmd = new SqlCommand(@"
                    UPDATE Wallets SET CurrentBalance = @NewBalance, LastUpdated = GETDATE()
                    WHERE UserID = @UserID", conn))
				{
					cmd.Parameters.AddWithValue("@NewBalance", newBalance);
					cmd.Parameters.AddWithValue("@UserID", UserID);
					cmd.ExecuteNonQuery();
				}
			}

			// clear input and refresh displayed balance on success
			txtAmount.Text = "";
			LoadCurrentBalance();
			ShowSuccess($"Successfully withdrew \u20B1{amount:N2} from your account!");
		}

		// helpers to toggle error and success message panels
		private void ShowError(string msg)
		{
			pnlError.Visible = true;
			pnlSuccess.Visible = false;
			lblError.Text = msg;
		}

		private void ShowSuccess(string msg)
		{
			pnlSuccess.Visible = true;
			pnlError.Visible = false;
			lblSuccess.Text = msg;
		}
	}
}