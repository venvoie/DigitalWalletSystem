<%@ Page Title="Statement of Account" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StatementOfAccount.aspx.cs" Inherits="DigitalWalletSystem.Pages.Reports.StatementOfAccount" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Filter Card --%>
    <div class="card" style="margin-bottom: 20px;">
        <div class="card-title">Statement of Account</div>

        <%-- Error message --%>
        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div class="alert alert-error">
                <asp:Label ID="lblError" runat="server" Text="" />
            </div>
        </asp:Panel>

        <div style="display: flex; gap: 16px; align-items: flex-end; flex-wrap: wrap;">

            <%-- From Date --%>
            <div class="form-group" style="margin-bottom: 0;">
                <label class="form-label">From</label>
                <asp:TextBox ID="txtFrom" runat="server"
                    TextMode="Date"
                    CssClass="form-control"
                    style="width: 180px;" />
                <asp:RequiredFieldValidator ID="rfvFrom" runat="server"
                    ControlToValidate="txtFrom"
                    ErrorMessage="From date is required."
                    CssClass="alert alert-error"
                    Display="Dynamic"
                    ValidationGroup="ReportGroup" />
            </div>

            <%-- To Date --%>
            <div class="form-group" style="margin-bottom: 0;">
                <label class="form-label">To</label>
                <asp:TextBox ID="txtTo" runat="server"
                    TextMode="Date"
                    CssClass="form-control"
                    style="width: 180px;" />
                <asp:RequiredFieldValidator ID="rfvTo" runat="server"
                    ControlToValidate="txtTo"
                    ErrorMessage="To date is required."
                    CssClass="alert alert-error"
                    Display="Dynamic"
                    ValidationGroup="ReportGroup" />
            </div>

            <%-- List Button --%>
            <asp:Button ID="btnList" runat="server"
                Text="List"
                CssClass="btn btn-primary"
                OnClick="btnList_Click"
                ValidationGroup="ReportGroup"
                style="width: auto; padding: 10px 28px;" />

        </div>
    </div>

    <%-- Results Card --%>
    <asp:Panel ID="pnlResults" runat="server" Visible="false">
        <div class="card">
            <div class="section-header">
                <div class="section-title">
                    Transaction History &nbsp;
                    <span style="font-size:13px; font-weight:400; color:var(--text-muted);">
                        (<asp:Label ID="lblDateRange" runat="server" Text="" />)
                    </span>
                </div>
                <span style="font-size:13px; color:var(--text-secondary);">
                    <asp:Label ID="lblRowCount" runat="server" Text="" /> record(s)
                </span>
            </div>

            <div class="table-wrap">
                <table class="cm-table">
                    <thead>
                        <tr>
                            <th>Seq. #</th>
                            <th>Type</th>
                            <th>Date &amp; Time</th>
                            <th>Debit</th>
                            <th>Credit</th>
                            <th>Balance</th>
                            <th>Sent To</th>
                            <th>Received From</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptStatement" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%# Container.ItemIndex + 1 %></td>
                                    <td>
                                        <span class="txn-badge <%# GetBadgeClass(Eval("TransactionType").ToString()) %>">
                                            <%# GetTypeLabel(Eval("TransactionType").ToString()) %>
                                        </span>
                                    </td>
                                    <td class="mono"><%# Eval("TransactionDate", "{0:MM/dd/yyyy hh:mm tt}") %></td>
                                    <td class="amount-neg"><%# Eval("Debit") != DBNull.Value ? "₱" + string.Format("{0:N2}", Eval("Debit")) : "—" %></td>
                                    <td class="amount-pos"><%# Eval("Credit") != DBNull.Value ? "₱" + string.Format("{0:N2}", Eval("Credit")) : "—" %></td>
                                    <td class="mono"><strong>₱<%# Eval("BalanceAfter", "{0:N2}") %></strong></td>
                                    <td class="mono"><%# Eval("SentToAccountNo") != DBNull.Value && Eval("SentToAccountNo").ToString() != "" ? Eval("SentToAccountNo").ToString() : "—" %></td>
                                    <td class="mono"><%# Eval("ReceivedFromAccountNo") != DBNull.Value && Eval("ReceivedFromAccountNo").ToString() != "" ? Eval("ReceivedFromAccountNo").ToString() : "—" %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            <%-- No records message --%>
            <asp:Panel ID="pnlNoRecords" runat="server" Visible="false">
                <p class="text-muted" style="text-align:center; padding: 24px 0; font-size:13px;">
                    No transactions found for the selected date range.
                </p>
            </asp:Panel>

        </div>
    </asp:Panel>

</asp:Content>
