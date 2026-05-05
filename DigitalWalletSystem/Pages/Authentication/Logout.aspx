<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Logout.aspx.cs" Inherits="DigitalWalletSystem.Pages.Authentication.Logout" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Logging Out — CloudMoney</title>
    <link href="~/Styles/Site.css" rel="stylesheet" type="text/css" runat="server" />
    <style>
        .logout-overlay {
            min-height: 100vh;
            background: var(--bg-shell);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .logout-box {
            background: #fff;
            border-radius: 18px;
            box-shadow: 0 6px 30px rgba(30,60,120,.12);
            padding: 48px 40px;
            text-align: center;
            width: 340px;
        }
        .logout-icon {
            width: 68px; height: 68px;
            border-radius: 50%;
            background: #fee2e2;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px;
            font-size: 28px;
        }
        .logout-title {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 8px;
        }
        .logout-sub {
            font-size: 13px;
            color: var(--text-secondary);
            margin-bottom: 28px;
            line-height: 1.6;
        }
        .btn-row {
            display: flex;
            gap: 10px;
        }
        .btn-row .btn {
            flex: 1;
        }
        .btn-cancel {
            background: var(--accent-light);
            color: var(--accent);
            border: none;
        }
        .btn-cancel:hover {
            background: #bfdbfe;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="logout-overlay">
            <div class="logout-box">

                <div class="logout-icon">&#9099;</div>

                <div class="logout-title">Log Out</div>
                <div class="logout-sub">
                    Are you sure you want to log out of CloudMoney?<br />
                    You will be redirected to the login page.
                </div>

                <div class="btn-row">
                    <asp:Button ID="btnCancel" runat="server"
                        Text="Cancel"
                        CssClass="btn btn-cancel"
                        OnClick="btnCancel_Click" />

                    <asp:Button ID="btnLogout" runat="server"
                        Text="Yes, Log Out"
                        CssClass="btn btn-danger"
                        OnClick="btnLogout_Click" />
                </div>

            </div>
        </div>
    </form>
</body>
</html>
