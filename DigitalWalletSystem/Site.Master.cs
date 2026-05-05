using System;
using System.Web.UI;

namespace DigitalWalletSystem
{
	public partial class SiteMaster : MasterPage
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			// Redirect to login if session is missing
			if (Session["UserID"] == null)
			{
				string path = Request.Url.AbsolutePath.ToLower();
				bool isAuthPage = path.Contains("login") || path.Contains("register");
				if (!isAuthPage)
					Response.Redirect("~/Pages/Authentication/Login.aspx");
			}
			else
			{
				// Auto-populate topbar from session on every page load
				SetUserInfo(
					Session["FullName"].ToString(),
					Session["AccountNumber"].ToString()
				);
			}
		}

		// Called by content pages to set topbar user info
		public void SetUserInfo(string fullName, string accountNumber)
		{
			lblUserName.Text = fullName;
			lblAccountNo.Text = accountNumber;

			// Generate initials for avatar (e.g. "Juan Dela Cruz" -> "JD")
			string[] parts = fullName.Split(' ');
			string initials = "";
			if (parts.Length >= 2)
				initials = parts[0][0].ToString() + parts[parts.Length - 1][0].ToString();
			else if (parts.Length == 1 && parts[0].Length > 0)
				initials = parts[0][0].ToString();

			lblInitials.Text = initials.ToUpper();
		}
	}
}