<%@ Page Title="Send CloudMoney" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SendMoney.aspx.cs" Inherits="DigitalWalletSystem.Pages.Main.SendMoney" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="card" style="max-width: 500px;">
        <div class="card-title">Send CloudMoney</div>

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

        <%-- STEP 1: Recipient Account Number --%>
        <div class="form-group">
            <label class="form-label">Recipient Account Number</label>
            <div style="display: flex; gap: 8px;">
                <asp:TextBox ID="txtRecipientAccount" runat="server"
                    CssClass="form-control"
                    placeholder="Enter 10-digit account number"
                    MaxLength="10"
                    style="flex: 1;" />
                <asp:Button ID="btnVerify" runat="server"
                    Text="Verify"
                    CssClass="btn btn-secondary"
                    OnClick="btnVerify_Click"
                    CausesValidation="false"
                    style="width: auto; padding: 10px 20px;" />
            </div>
            <asp:RequiredFieldValidator ID="rfvRecipient" runat="server"
                ControlToValidate="txtRecipientAccount"
                ErrorMessage="Please enter a recipient account number."
                CssClass="alert alert-error"
                Display="Dynamic"
                ValidationGroup="SendGroup" />
        </div>

        <%-- Recipient Details Panel (shown after verify) --%>
        <asp:Panel ID="pnlRecipient" runat="server" Visible="false">
            <div class="alert alert-success" style="margin-bottom: 20px;">
                <strong>Recipient Verified &#10003;</strong><br />
                <table style="margin-top: 8px; font-size: 13px; width: 100%;">
                    <tr>
                        <td style="width: 120px; color: var(--text-secondary);">Account No.</td>
                        <td><strong><asp:Label ID="lblRecipientAccountNo" runat="server" Text="" /></strong></td>
                    </tr>
                    <tr>
                        <td style="color: var(--text-secondary);">Name</td>
                        <td><strong><asp:Label ID="lblRecipientName" runat="server" Text="" /></strong></td>
                    </tr>
                </table>
            </div>

            <%-- Hidden field to store recipient UserID --%>
            <asp:HiddenField ID="hfRecipientUserID" runat="server" Value="" />

            <%-- Amount --%>
            <div class="form-group">
                <label class="form-label">Amount to Send</label>
                <asp:TextBox ID="txtAmount" runat="server"
                    CssClass="form-control"
                    placeholder="e.g. 500"
                    MaxLength="10" />
                <asp:RequiredFieldValidator ID="rfvAmount" runat="server"
                    ControlToValidate="txtAmount"
                    ErrorMessage="Please enter an amount."
                    CssClass="alert alert-error"
                    Display="Dynamic"
                    ValidationGroup="SendGroup" />
                <asp:RegularExpressionValidator ID="revAmount" runat="server"
                    ControlToValidate="txtAmount"
                    ValidationExpression="^\d+(\.\d{1,2})?$"
                    ErrorMessage="Please enter a valid amount."
                    CssClass="alert alert-error"
                    Display="Dynamic"
                    ValidationGroup="SendGroup" />
            </div>

            <%-- Password verification --%>
            <div class="form-group">
                <label class="form-label">Your Password <span style="color:var(--text-muted); font-weight:400;">(required for security)</span></label>
                <asp:TextBox ID="txtPassword" runat="server"
                    TextMode="Password"
                    CssClass="form-control"
                    placeholder="Enter your password to confirm" />
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                    ControlToValidate="txtPassword"
                    ErrorMessage="Please enter your password to confirm."
                    CssClass="alert alert-error"
                    Display="Dynamic"
                    ValidationGroup="SendGroup" />
            </div>

            <%-- Rules info box --%>
            <div class="alert alert-info" style="margin-bottom: 20px;">
                <strong>Send Rules:</strong><br />
                &#8226; Minimum amount: <strong>&#8369;100.00</strong><br />
                &#8226; Maximum amount per transaction: <strong>&#8369;2,000.00</strong><br />
                &#8226; Amount must be divisible by <strong>&#8369;100.00</strong><br />
                &#8226; Transaction will be rejected if funds are insufficient
            </div>

            <%-- Submit --%>
            <asp:Button ID="btnSend" runat="server"
                Text="Send CloudMoney"
                CssClass="btn btn-primary"
                OnClick="btnSend_Click"
                ValidationGroup="SendGroup"
                style="width: auto; padding: 10px 32px;" />

        </asp:Panel>

    </div>

</asp:Content>
