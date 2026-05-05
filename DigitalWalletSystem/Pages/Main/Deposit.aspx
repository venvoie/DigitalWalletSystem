<%@ Page Title="Deposit" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Deposit.aspx.cs" Inherits="DigitalWalletSystem.Pages.Main.Deposit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="card" style="max-width: 480px;">
        <div class="card-title">Deposit Funds</div>

        <%-- Current Balance Display --%>
        <div class="balance-card" style="margin-bottom: 24px; padding: 16px 20px;">
            <div>
                <div class="balance-label">Current Balance</div>
                <div class="balance-amount" style="font-size: 26px;">
                    &#8369; <asp:Label ID="lblCurrentBalance" runat="server" Text="0.00" />
                </div>
            </div>
        </div>

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

        <%-- Amount --%>
        <div class="form-group">
            <label class="form-label">Amount to Deposit</label>
            <asp:TextBox ID="txtAmount" runat="server"
                CssClass="form-control"
                placeholder="e.g. 500"
                MaxLength="10" />
            <asp:RequiredFieldValidator ID="rfvAmount" runat="server"
                ControlToValidate="txtAmount"
                ErrorMessage="Please enter an amount."
                CssClass="alert alert-error"
                Display="Dynamic" />
            <asp:RegularExpressionValidator ID="revAmount" runat="server"
                ControlToValidate="txtAmount"
                ValidationExpression="^\d+(\.\d{1,2})?$"
                ErrorMessage="Please enter a valid amount."
                CssClass="alert alert-error"
                Display="Dynamic" />
        </div>

        <%-- Rules info box --%>
        <div class="alert alert-info" style="margin-bottom: 20px;">
            <strong>Deposit Rules:</strong><br />
            &#8226; Minimum deposit: <strong>&#8369;100.00</strong><br />
            &#8226; Maximum deposit per transaction: <strong>&#8369;2,000.00</strong><br />
            &#8226; Amount must be divisible by <strong>&#8369;100.00</strong><br />
            &#8226; Total balance must not exceed <strong>&#8369;10,000.00</strong>
        </div>

        <%-- Submit --%>
        <asp:Button ID="btnDeposit" runat="server"
            Text="Deposit"
            CssClass="btn btn-primary"
            OnClick="btnDeposit_Click"
            style="width: auto; padding: 10px 32px;" />

    </div>

</asp:Content>
