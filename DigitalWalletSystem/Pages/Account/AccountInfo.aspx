<%@ Page Title="Account Info" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccountInfo.aspx.cs" Inherits="DigitalWalletSystem.Pages.Account.AccountInfo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="card" style="max-width: 620px;">
        <div class="card-title">Account Information</div>

        <%-- Account No. --%>
        <div class="info-row">
            <div class="info-key">Account Number</div>
            <div class="info-val mono">
                <asp:Label ID="lblAccountNumber" runat="server" Text="" />
            </div>
        </div>

        <%-- Full Name --%>
        <div class="info-row">
            <div class="info-key">Full Name</div>
            <div class="info-val">
                <asp:Label ID="lblFullName" runat="server" Text="" />
            </div>
        </div>

        <%-- Username --%>
        <div class="info-row">
            <div class="info-key">Username</div>
            <div class="info-val">
                <asp:Label ID="lblUsername" runat="server" Text="" />
            </div>
        </div>

        <%-- Email --%>
        <div class="info-row">
            <div class="info-key">Email Address</div>
            <div class="info-val">
                <asp:Label ID="lblEmail" runat="server" Text="" />
            </div>
        </div>

        <%-- Date Registered --%>
        <div class="info-row">
            <div class="info-key">Date Registered</div>
            <div class="info-val">
                <asp:Label ID="lblDateRegistered" runat="server" Text="" />
            </div>
        </div>

        <%-- Current Balance --%>
        <div class="info-row">
            <div class="info-key">Current Balance</div>
            <div class="info-val">
                <span style="color: var(--green); font-weight: 700; font-size: 15px;">
                    &#8369; <asp:Label ID="lblBalance" runat="server" Text="0.00" />
                </span>
            </div>
        </div>

        <%-- Total Sent --%>
        <div class="info-row">
            <div class="info-key">Total Sent</div>
            <div class="info-val">
                <span style="color: var(--red); font-weight: 600;">
                    &#8369; <asp:Label ID="lblTotalSent" runat="server" Text="0.00" />
                </span>
            </div>
        </div>

        <%-- Status --%>
        <div class="info-row">
            <div class="info-key">Account Status</div>
            <div class="info-val">
                <asp:Label ID="lblStatus" runat="server" Text="" />
            </div>
        </div>

        <%-- Action buttons --%>
        <div style="margin-top: 24px; display: flex; gap: 10px;">
            <a href="~/Pages/Account/ChangePassword.aspx" runat="server" class="btn btn-secondary" style="text-decoration:none; width:auto; padding: 10px 20px;">
                &#128274; Change Password
            </a>
            <a href="~/Pages/Authentication/Logout.aspx" runat="server" class="btn btn-danger" style="text-decoration:none; width:auto; padding: 10px 20px;">
                &#9099; Log Out
            </a>
        </div>

    </div>

</asp:Content>
