<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="DigitalWalletSystem.Pages.Authentication.Login" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sign In — CloudMoney</title>
    <link href="~/Styles/Site.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="auth-page">
            <div class="auth-card">

                <%-- Logo --%>
                <div class="auth-logo">
                    <div class="auth-logo-icon">&#9729;</div>
                    <div class="auth-logo-name">CloudMoney</div>
                    <div class="auth-logo-sub">Digital Wallet</div>
                </div>

                <div class="auth-heading">Sign in to your account</div>

                <%-- Error message --%>
                <asp:Panel ID="pnlError" runat="server" Visible="false">
                    <div class="alert alert-error">
                        <asp:Label ID="lblError" runat="server" Text="" />
                    </div>
                </asp:Panel>

                <%-- Account Number --%>
                <div class="form-group">
                    <label class="form-label">Account Number</label>
                    <asp:TextBox ID="txtAccountNumber" runat="server"
                        CssClass="form-control"
                        placeholder="Enter your account number"
                        MaxLength="10" />
                    <asp:RequiredFieldValidator ID="rfvAccountNumber" runat="server"
                        ControlToValidate="txtAccountNumber"
                        ErrorMessage="Account number is required."
                        CssClass="alert alert-error"
                        Display="Dynamic" />
                </div>

                <%-- Password --%>
                <div class="form-group">
                    <label class="form-label">Password</label>
                    <asp:TextBox ID="txtPassword" runat="server"
                        TextMode="Password"
                        CssClass="form-control"
                        placeholder="Enter your password" />
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                        ControlToValidate="txtPassword"
                        ErrorMessage="Password is required."
                        CssClass="alert alert-error"
                        Display="Dynamic" />
                </div>

                <%-- Submit --%>
                <asp:Button ID="btnLogin" runat="server"
                    Text="Sign In"
                    CssClass="btn btn-primary"
                    OnClick="btnLogin_Click" />

                <%-- Register link --%>
                <div class="auth-footer">
                    Not registered yet?
                    <a href="~/Pages/Authentication/Register.aspx" runat="server">Create an account</a>
                </div>

            </div>
        </div>
    </form>
</body>
</html>
