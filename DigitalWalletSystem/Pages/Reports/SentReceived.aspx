<%@ Page Title="Sent & Received Transactions" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SentReceived.aspx.cs" Inherits="DigitalWalletSystem.Pages.Reports.SentReceived" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Filter Card --%>
    <div class="card" style="margin-bottom: 20px;">
        <div class="card-title">Sent &amp; Received Transactions</div>

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

            <%-- Type Filter --%>
            <div class="form-group" style="margin-bottom: 0;">
                <label class="form-label">Type</label>
                <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control" style="width: 160px;">
                    <asp:ListItem Text="All"      Value="All"  Selected="True" />
                    <asp:ListItem Text="Sent"     Value="S" />
                    <asp:ListItem Text="Received" Value="R" />
                </asp:DropDownList>
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
                    Results &nbsp;
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
                            <th>Amount</th>
                            <th>Sent To</th>
                            <th>Received From</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptResults" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%# Container.ItemIndex + 1 %></td>
                                    <td>
                                        <span class="txn-badge <%# Eval("TransactionType").ToString() == "S" ? "send" : "receive" %>">
                                            <%# Eval("TransactionType").ToString() == "S" ? "Sent" : "Received" %>
                                        </span>
                                    </td>
                                    <td class="mono"><%# Eval("TransactionDate", "{0:MM/dd/yyyy hh:mm tt}") %></td>
                                    <td class='<%# Eval("TransactionType").ToString() == "S" ? "amount-neg" : "amount-pos" %>'>
                                        <%# Eval("TransactionType").ToString() == "S" ? "-" : "+" %>&#8369;<%# Eval("Amount", "{0:N2}") %>
                                    </td>
                                    <td class="mono">
                                        <%# Eval("SentToAccountNo") != DBNull.Value && Eval("SentToAccountNo").ToString() != ""
                                            ? Eval("SentToAccountNo").ToString()
                                            : "—" %>
                                    </td>
                                    <td class="mono">
                                        <%# Eval("ReceivedFromAccountNo") != DBNull.Value && Eval("ReceivedFromAccountNo").ToString() != ""
                                            ? Eval("ReceivedFromAccountNo").ToString()
                                            : "—" %>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            <%-- No records message --%>
            <asp:Panel ID="pnlNoRecords" runat="server" Visible="false">
                <p class="text-muted" style="text-align:center; padding: 24px 0; font-size:13px;">
                    No records found for the selected date range and type.
                </p>
            </asp:Panel>

        </div>
    </asp:Panel>

</asp:Content>
