using System;
using System.Web;
using System.Web.Routing;

namespace DigitalWalletSystem
{
	public class Global : HttpApplication
	{
		protected void Application_Start(object sender, EventArgs e)
		{
			System.Web.UI.ValidationSettings.UnobtrusiveValidationMode =
				System.Web.UI.UnobtrusiveValidationMode.None;
		}

		protected void Session_Start(object sender, EventArgs e) { }
		protected void Application_BeginRequest(object sender, EventArgs e) { }
		protected void Application_Error(object sender, EventArgs e) { }
		protected void Session_End(object sender, EventArgs e) { }
		protected void Application_End(object sender, EventArgs e) { }
	}
}