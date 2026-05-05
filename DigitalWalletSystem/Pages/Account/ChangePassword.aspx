<%@ Page Title="Change Password" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="DigitalWalletSystem.Pages.Account.ChangePassword" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="card" style="max-width: 480px;">
        <div class="card-title">Change Password</div>

        <%-- Error message --%>
        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div class="alert alert-error">
                <asp:Label ID="lblError" runat="server" Text="" />
            </div>
        </asp:Panel>

        <%-- Success message --%>
        <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
            <div class="alert alert-success">
                <asp:Label ID="lblSuccess" runat="server" Text="" />
            </div>
        </asp:Panel>

        <%-- Current Password --%>
        <div class="form-group">
            <label class="form-label">Current Password</label>
            <asp:TextBox ID="txtCurrentPassword" runat="server"
                TextMode="Password"
                CssClass="form-control"
                placeholder="Enter your current password" />
            <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server"
                ControlToValidate="txtCurrentPassword"
                ErrorMessage="Current password is required."
                CssClass="alert alert-error"
                Display="Dynamic" />
        </div>

        <%-- New Password --%>
        <div class="form-group">
            <label class="form-label">New Password</label>
            <asp:TextBox ID="txtNewPassword" runat="server"
                TextMode="Password"
                CssClass="form-control"
                placeholder="Enter your new password" />
            <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server"
                ControlToValidate="txtNewPassword"
                ErrorMessage="New password is required."
                CssClass="alert alert-error"
                Display="Dynamic" />
            <asp:RegularExpressionValidator ID="revNewPassword" runat="server"
                ControlToValidate="txtNewPassword"
                ValidationExpression=".{8,}"
                ErrorMessage="New password must be at least 8 characters."
                CssClass="alert alert-error"
                Display="Dynamic" />
        </div>

        <%-- Confirm New Password --%>
        <div class="form-group">
            <label class="form-label">Confirm New Password</label>
            <asp:TextBox ID="txtConfirmPassword" runat="server"
                TextMode="Password"
                CssClass="form-control"
                placeholder="Re-enter your new password" />
            <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server"
                ControlToValidate="txtConfirmPassword"
                ErrorMessage="Please confirm your new password."
                CssClass="alert alert-error"
                Display="Dynamic" />
            <asp:CompareValidator ID="cvPasswords" runat="server"
                ControlToValidate="txtConfirmPassword"
                ControlToCompare="txtNewPassword"
                ErrorMessage="Passwords do not match."
                CssClass="alert alert-error"
                Display="Dynamic" />
        </div>

        <%-- Buttons --%>
        <div style="display: flex; gap: 10px; margin-top: 8px;">
            <asp:Button ID="btnChangePassword" runat="server"
                Text="Update Password"
                CssClass="btn btn-primary"
                OnClick="btnChangePassword_Click"
                style="width: auto; padding: 10px 24px;" />
            <a href="~/Pages/Account/AccountInfo.aspx" runat="server"
                class="btn btn-secondary"
                style="text-decoration: none; width: auto; padding: 10px 20px;">
                Cancel
            </a>
        </div>

    </div>

</asp:Content>
