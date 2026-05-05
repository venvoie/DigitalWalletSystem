<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="DigitalWalletSystem.Pages.Authentication.Register" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Create Account — CloudMoney</title>
    <link href="~/Styles/Site.css" rel="stylesheet" type="text/css" />
    <style>
        .register-card { max-width: 520px; }
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0 16px;
        }
        .form-grid .form-group { margin-bottom: 14px; }
        .form-group-full { grid-column: 1 / -1; }
        .cb-row {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            margin-bottom: 16px;
            margin-top: 4px;
        }
        .cb-row input[type="checkbox"] {
            width: 16px; height: 16px;
            margin-top: 3px;
            flex-shrink: 0;
            accent-color: var(--accent);
        }
        .cb-row label {
            font-size: 12.5px;
            color: var(--text-secondary);
            line-height: 1.6;
        }
        .cb-row label a { color: var(--accent); font-weight: 600; }

        /* Success overlay */
        .success-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(15, 30, 60, 0.55);
            z-index: 999;
            align-items: center;
            justify-content: center;
        }
        .success-overlay.show { display: flex; }
        .success-box {
            background: #fff;
            border-radius: 18px;
            padding: 48px 40px;
            text-align: center;
            width: 320px;
            box-shadow: 0 8px 40px rgba(0,0,0,0.18);
        }
        .success-icon {
            width: 68px; height: 68px;
            border-radius: 50%;
            background: #dbeafe;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 18px;
            font-size: 32px;
        }
        .success-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 8px;
        }
        .success-sub {
            font-size: 13px;
            color: var(--text-secondary);
            margin-bottom: 20px;
        }
        .progress-bar {
            height: 5px;
            background: #e5e7eb;
            border-radius: 3px;
            overflow: hidden;
        }
        .progress-fill {
            height: 100%;
            background: var(--accent);
            width: 0%;
            transition: width 2.8s linear;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <%-- Success Popup Overlay --%>
        <div class="success-overlay" id="successOverlay">
            <div class="success-box">
                <div class="success-icon">&#10003;</div>
                <div class="success-title">Account Created!</div>
                <div class="success-sub">Welcome to CloudMoney. Redirecting to login...</div>
                <div class="progress-bar">
                    <div class="progress-fill" id="progressFill"></div>
                </div>
            </div>
        </div>

        <div class="auth-page">
            <div class="auth-card register-card">

                <%-- Logo --%>
                <div class="auth-logo">
                    <div class="auth-logo-icon">&#9729;</div>
                    <div class="auth-logo-name">CloudMoney</div>
                    <div class="auth-logo-sub">Create Your Account</div>
                </div>

                <div class="auth-heading">Register a new account</div>

                <%-- Error / Success messages --%>
                <asp:Panel ID="pnlError" runat="server" Visible="false">
                    <div class="alert alert-error">
                        <asp:Label ID="lblError" runat="server" Text="" />
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
                    <div class="alert alert-success">
                        <asp:Label ID="lblSuccess" runat="server" Text="" />
                    </div>
                </asp:Panel>

                <div class="form-grid">
                    <%-- First Name --%>
                    <div class="form-group">
                        <label class="form-label">First Name</label>
                        <asp:TextBox ID="txtFirstName" runat="server"
                            CssClass="form-control"
                            placeholder="Juan"
                            MaxLength="50" />
                        <asp:RequiredFieldValidator ID="rfvFirstName" runat="server"
                            ControlToValidate="txtFirstName"
                            ErrorMessage="First name is required."
                            CssClass="alert alert-error"
                            Display="Dynamic" />
                    </div>

                    <%-- Last Name --%>
                    <div class="form-group">
                        <label class="form-label">Last Name</label>
                        <asp:TextBox ID="txtLastName" runat="server"
                            CssClass="form-control"
                            placeholder="Dela Cruz"
                            MaxLength="50" />
                        <asp:RequiredFieldValidator ID="rfvLastName" runat="server"
                            ControlToValidate="txtLastName"
                            ErrorMessage="Last name is required."
                            CssClass="alert alert-error"
                            Display="Dynamic" />
                    </div>

                    <%-- Email --%>
                    <div class="form-group">
                        <label class="form-label">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server"
                            CssClass="form-control"
                            placeholder="juan@email.com"
                            MaxLength="100" />
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                            ControlToValidate="txtEmail"
                            ErrorMessage="Email is required."
                            CssClass="alert alert-error"
                            Display="Dynamic" />
                        <asp:RegularExpressionValidator ID="revEmail" runat="server"
                            ControlToValidate="txtEmail"
                            ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                            ErrorMessage="Enter a valid email address."
                            CssClass="alert alert-error"
                            Display="Dynamic" />
                    </div>

                    <%-- Username --%>
                    <div class="form-group">
                        <label class="form-label">Username</label>
                        <asp:TextBox ID="txtUsername" runat="server"
                            CssClass="form-control"
                            placeholder="juandc"
                            MaxLength="50" />
                        <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                            ControlToValidate="txtUsername"
                            ErrorMessage="Username is required."
                            CssClass="alert alert-error"
                            Display="Dynamic" />
                    </div>

                    <%-- Password --%>
                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <asp:TextBox ID="txtPassword" runat="server"
                            TextMode="Password"
                            CssClass="form-control"
                            placeholder="Create a password" />
                        <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                            ControlToValidate="txtPassword"
                            ErrorMessage="Password is required."
                            CssClass="alert alert-error"
                            Display="Dynamic" />
                        <asp:RegularExpressionValidator ID="revPassword" runat="server"
                            ControlToValidate="txtPassword"
                            ValidationExpression=".{6,}"
                            ErrorMessage="Password must be at least 6 characters."
                            CssClass="alert alert-error"
                            Display="Dynamic" />
                    </div>

                    <%-- Confirm Password --%>
                    <div class="form-group">
                        <label class="form-label">Confirm Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server"
                            TextMode="Password"
                            CssClass="form-control"
                            placeholder="Re-enter password" />
                        <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server"
                            ControlToValidate="txtConfirmPassword"
                            ErrorMessage="Please confirm your password."
                            CssClass="alert alert-error"
                            Display="Dynamic" />
                        <asp:CompareValidator ID="cvPassword" runat="server"
                            ControlToValidate="txtConfirmPassword"
                            ControlToCompare="txtPassword"
                            ErrorMessage="Passwords do not match."
                            CssClass="alert alert-error"
                            Display="Dynamic" />
                    </div>
                </div>

                <%-- Terms and Conditions checkbox --%>
                <div class="cb-row">
                    <asp:CheckBox ID="chkTerms" runat="server" />
                    <label for="<%= chkTerms.ClientID %>">
                        I have read and agree to the
                        <a href="#">Terms and Conditions</a> and
                        <a href="#">Privacy Policy</a> of CloudMoney.
                    </label>
                </div>

                <%-- Submit --%>
                <asp:Button ID="btnRegister" runat="server"
                    Text="Create Account"
                    CssClass="btn btn-primary"
                    OnClick="btnRegister_Click" />

                <div class="auth-footer">
                    Already have an account?
                    <a href="~/Pages/Authentication/Login.aspx" runat="server">Sign in</a>
                </div>

            </div>
        </div>

    </form>

    <script>
		// Triggered from code-behind via ScriptManager
		function showSuccessAndRedirect() {
			var overlay = document.getElementById('successOverlay');
			overlay.classList.add('show');
			var fill = document.getElementById('progressFill');
			setTimeout(function () { fill.style.width = '100%'; }, 50);
			setTimeout(function () {
				window.location.href = '/Pages/Authentication/Login.aspx';
            }, 3000);
        }
	</script>
</body>
</html>
