<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Logout.aspx.cs" Inherits="DigitalWalletSystem.Pages.Authentication.Logout" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>CloudMoney • Log Out</title>
    <link href="~/Styles/Site.css" rel="stylesheet" type="text/css" runat="server" />
    <style>
        .site-brand {
            position: fixed;
            top: 18px;
            left: 24px;
            display: flex;
            flex-direction: column;
            gap: 2px;
            pointer-events: none;
            z-index: 100;
        }
        .site-brand-name { font-size: 15px; font-weight: 700; color: var(--text-muted); }
        .site-brand-sub  { font-size: 11px; font-weight: 400; color: var(--text-muted); opacity: 0.6; }

        .site-footer {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            text-align: center;
            padding: 12px;
            font-size: 12px;
            color: var(--text-muted);
            opacity: 0.6;
        }

        .logout-icon {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            background: #fee2e2;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 28px;
        }

        .logout-sub {
            font-size: 13px;
            color: var(--text-secondary);
            margin-bottom: 28px;
            line-height: 1.6;
            text-align: center;
        }

        .btn-row { display: flex; gap: 10px; }
        .btn-row .btn { flex: 1; }
    </style>
</head>

<body>

    <%-- top-left cloudmoney --%>
    <div class="site-brand">
        <div class="site-brand-name">&#9729; CloudMoney</div>
        <div class="site-brand-sub">Digital Wallet</div>
    </div>

    <%-- copyright footer --%>
    <div class="site-footer">&copy; <%= DateTime.Now.Year %> CloudMoney. All rights reserved.</div>

    <form id="form1" runat="server">
        <div class="auth-page">
            <div class="auth-card">

                <div class="logout-icon">&#9099;</div>
                <div class="auth-heading">Log Out</div>

                <%-- confirmation message --%>
                <div class="logout-sub">
                    Are you sure you want to log out of CloudMoney?<br />
                    You will be redirected to the login page.
                </div>

                <%-- cancel and confirm buttons --%>
                <div class="btn-row">
                    <asp:Button ID="btnCancel" runat="server"
                        Text="Cancel" CssClass="btn btn-secondary"
                        OnClick="btnCancel_Click" />
                    <asp:Button ID="btnLogout" runat="server"
                        Text="Yes, Log Out" CssClass="btn btn-danger"
                        OnClick="btnLogout_Click" />
                </div>

            </div>
        </div>
    </form>

</body>
</html>