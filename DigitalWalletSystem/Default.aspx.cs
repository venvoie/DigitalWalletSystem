using System;

namespace DigitalWalletSystem
{
	public partial class _Default : System.Web.UI.Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			Response.Redirect("~/Pages/Authentication/Login.aspx");
		}
	}
}