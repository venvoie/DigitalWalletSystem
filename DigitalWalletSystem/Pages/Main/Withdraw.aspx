<%@ Page Title="Withdraw" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Withdraw.aspx.cs" Inherits="DigitalWalletSystem.Pages.Main.Withdraw" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>

        /* stretch the card to fill available width with matching side margins */
        .withdraw-card {
            max-width: calc(100% - 48px);
            width: 100%;
            margin-left: auto;
            margin-right: auto;
            box-sizing: border-box;
        }

        /* confirmation modal overlay */
        #confirmModal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.45);
            z-index: 9999;
            align-items: center;
            justify-content: center;
        }

        #confirmModal.active { display: flex; }

        /* modal box */
        .modal-box {
            background: #fff;
            border-radius: 12px;
            padding: 32px 28px 24px;
            max-width: 380px;
            width: 90%;
            box-shadow: 0 8px 32px rgba(0,0,0,0.18);
            text-align: center;
        }

        .modal-box h3 { margin: 0 0 8px; font-size: 1.15rem; }
        .modal-box p  { margin: 0 0 24px; color: #555; font-size: 0.95rem; }

        .modal-actions { display: flex; gap: 12px; justify-content: center; }

        .modal-actions .btn-cancel {
            padding: 10px 24px;
            border: 1px solid #ccc;
            border-radius: 6px;
            background: #f5f5f5;
            cursor: pointer;
            font-size: 0.95rem;
        }

        .modal-actions .btn-confirm {
            padding: 10px 24px;
            border: none;
            border-radius: 6px;
            background: #2563eb;
            color: #fff;
            cursor: pointer;
            font-size: 0.95rem;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%-- confirmation modal --%>
    <div id="confirmModal">
        <div class="modal-box">
            <h3>Confirm Withdrawal</h3>
            <p id="confirmMsg">Are you sure you want to withdraw <strong id="confirmAmt"></strong>?</p>
            <div class="modal-actions">
                <button class="btn-cancel" onclick="closeModal()">Cancel</button>
                <button class="btn-confirm" onclick="submitWithdraw()">Yes, Withdraw</button>
            </div>
        </div>
    </div>

    <%-- main card — expanded horizontally --%>
    <div class="card withdraw-card">
        <div class="card-title">Withdraw Funds</div>

        <%-- current balance --%>
        <div class="balance-card" style="margin-bottom:24px; padding:16px 20px;">
            <div class="balance-label">Current Balance</div>
            <div class="balance-amount" style="font-size:26px;">
                &#8369; <asp:Label ID="lblCurrentBalance" runat="server" Text="0.00" />
            </div>
        </div>

        <%-- error alert --%>
        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div class="alert alert-error">
                <asp:Label ID="lblError" runat="server" />
            </div>
        </asp:Panel>

        <%-- success alert --%>
        <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
            <div class="alert alert-success">
                <asp:Label ID="lblSuccess" runat="server" />
            </div>
        </asp:Panel>

        <%-- amount input --%>
        <div class="form-group">
            <label class="form-label">Amount to Withdraw</label>
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

        <%-- withdrawal rules --%>
        <div class="alert alert-info" style="margin-bottom:20px;">
            <strong>Withdrawal Rules:</strong><br />
            &#8226; Minimum: <strong>&#8369;100.00</strong><br />
            &#8226; Maximum per transaction: <strong>&#8369;2,000.00</strong><br />
            &#8226; Must be divisible by <strong>&#8369;100.00</strong><br />
            &#8226; Insufficient funds will be rejected
        </div>

        <%-- withdraw button — triggers modal, not postback directly --%>
        <asp:Button ID="btnWithdraw" runat="server"
            Text="Withdraw"
            CssClass="btn btn-primary"
            OnClientClick="return openModal();"
            OnClick="btnWithdraw_Click"
            style="width:auto; padding:10px 32px;" />

        <%-- hidden real submit button used by the modal --%>
        <asp:Button ID="btnConfirmed" runat="server"
            Text="Confirmed"
            OnClick="btnWithdraw_Click"
            style="display:none;" />
    </div>

    <script>
		// open modal and show the formatted amount before confirming
		function openModal() {
			var raw = document.getElementById('<%= txtAmount.ClientID %>').value.trim();
            var num = parseFloat(raw);

            // let asp.net validators run first — abort modal if input is empty/invalid
            if (!raw || isNaN(num)) return true; // true = allow postback so validators fire

            document.getElementById('confirmAmt').textContent = '\u20B1' + num.toFixed(2);
            document.getElementById('confirmModal').classList.add('active');
            return false; // prevent postback until user confirms
        }

        // close the modal without submitting
        function closeModal() {
            document.getElementById('confirmModal').classList.remove('active');
        }

        // programmatically click the hidden confirmed button to trigger postback
        function submitWithdraw() {
            closeModal();
            document.getElementById('<%= btnConfirmed.ClientID %>').click();
		}
	</script>

</asp:Content>