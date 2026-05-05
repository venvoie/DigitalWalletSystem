<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="DigitalWalletSystem.Pages.Main.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Balance Hero Card --%>
    <div class="balance-card">
        <div>
            <div class="balance-label">Total Current Balance</div>
            <div class="balance-amount">
                &#8369; <asp:Label ID="lblBalance" runat="server" Text="0.00" />
            </div>
            <div class="balance-acct">
                Account No. &nbsp;<asp:Label ID="lblAccountNo" runat="server" Text="" />
            </div>
        </div>
        <div class="balance-card-right">
            <div class="balance-user-name">
                <asp:Label ID="lblFullName" runat="server" Text="" />
            </div>
            <div class="balance-since">
                Member since <asp:Label ID="lblDateRegistered" runat="server" Text="" />
            </div>
            <a href="~/Pages/Reports/StatementOfAccount.aspx" runat="server" class="btn-view-stmt">
                View Statement
            </a>
        </div>
    </div>

    <%-- Stats Row --%>
    <div class="stats-row">
        <div class="stat-card stat-sent">
            <div class="stat-label">Total Sent</div>
            <div class="stat-amount red">
                &#8369; <asp:Label ID="lblTotalSent" runat="server" Text="0.00" />
            </div>
            <div class="stat-sub">
                <asp:Label ID="lblSentCount" runat="server" Text="0" /> transaction(s)
            </div>
        </div>
        <div class="stat-card stat-recv">
            <div class="stat-label">Total Received</div>
            <div class="stat-amount green">
                &#8369; <asp:Label ID="lblTotalReceived" runat="server" Text="0.00" />
            </div>
            <div class="stat-sub">
                <asp:Label ID="lblReceivedCount" runat="server" Text="0" /> transaction(s)
            </div>
        </div>
        <div class="stat-card stat-dep">
            <div class="stat-label">Total Deposited</div>
            <div class="stat-amount blue">
                &#8369; <asp:Label ID="lblTotalDeposited" runat="server" Text="0.00" />
            </div>
            <div class="stat-sub">
                <asp:Label ID="lblDepositCount" runat="server" Text="0" /> deposit(s)
            </div>
        </div>
        <div class="stat-card stat-with">
            <div class="stat-label">Total Withdrawn</div>
            <div class="stat-amount orange">
                &#8369; <asp:Label ID="lblTotalWithdrawn" runat="server" Text="0.00" />
            </div>
            <div class="stat-sub">
                <asp:Label ID="lblWithdrawCount" runat="server" Text="0" /> withdrawal(s)
            </div>
        </div>
    </div>

    <%-- Two-column panels --%>
    <div class="panel-row">

        <%-- Recently Received CloudMoney --%>
        <div class="card">
            <div class="section-header">
                <div class="section-title">Recently Received CloudMoney</div>
            </div>
            <asp:Panel ID="pnlNoNotifs" runat="server" Visible="false">
                <p class="text-muted" style="font-size:13px;">No received transactions yet.</p>
            </asp:Panel>
            <div class="notif-list">
                <asp:Repeater ID="rptNotifications" runat="server">
                    <ItemTemplate>
                        <div class="notif-item">
                            <div class="notif-dot"></div>
                            <div>
                                <div class="notif-text">
                                    <strong><%# Eval("SenderName") %></strong>
                                    sent you
                                    <strong style="color:var(--green);">&#8369; <%# Eval("Amount", "{0:N2}") %></strong>
                                </div>
                                <div class="notif-time"><%# Eval("TransactionDate", "{0:MMM dd, yyyy hh:mm tt}") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <%-- Recent Transactions --%>
        <div class="card">
            <div class="section-header">
                <div class="section-title">Recent Transactions</div>
                <a href="~/Pages/Reports/StatementOfAccount.aspx" runat="server" class="view-all">View all</a>
            </div>
            <asp:Panel ID="pnlNoTxn" runat="server" Visible="false">
                <p class="text-muted" style="font-size:13px;">No transactions yet.</p>
            </asp:Panel>
            <div class="txn-list">
                <asp:Repeater ID="rptTransactions" runat="server">
                    <ItemTemplate>
                        <div class="txn-item">
                            <div class="txn-left">
                                <span class="txn-badge <%# GetBadgeClass(Eval("TransactionType").ToString()) %>">
                                    <%# GetTypeLabel(Eval("TransactionType").ToString()) %>
                                </span>
                                <span class="txn-date"><%# Eval("TransactionDate", "{0:MMM dd, yyyy}") %></span>
                            </div>
                            <span class="txn-amount <%# IsCredit(Eval("TransactionType").ToString()) ? "positive" : "negative" %>">
                                <%# IsCredit(Eval("TransactionType").ToString()) ? "+" : "-" %>&#8369;<%# Eval("Amount", "{0:N2}") %>
                            </span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

    </div>

</asp:Content>
