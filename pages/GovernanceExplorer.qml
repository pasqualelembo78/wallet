import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import "../components" as MevaCoinComponents

Rectangle {
    id: governancePage
    color: "transparent"
    property int contentHeight: mainColumn.implicitHeight + 40
    property var poolStats: ({})
    property var distributions: []
    property var recentBlocks: []
    property var treasuryTxs: []
    property var knownHeight: 0
    property var treasuryStatus: ({})
    property var netFundStatus: ({})
    property var govActivity: []
    property var proposerStatus: ({})
    property var nodePubkey: ""
    property var proposalList: []
    property var proposalVotes: []
    property string selectedProposalId: ""

    function onPageCompleted() {
        refresh();
    }

    function refresh() {
        connectionError = "";
        isLoading = true;
        mevatrustManager.getNetworkStats();
        mevatrustManager.getPoolDistributionHistory(50);
        mevatrustManager.getRecentBlocks(10);
        mevatrustManager.getTreasuryStatus();
        mevatrustManager.getNetworkFundStatus();
        mevatrustManager.getGovernanceActivity(0, 100);
        mevatrustManager.getProposerStatus();
        mevatrustManager.getNodePubkey();
    }

    function formatMVC(amount) {
        if (amount === undefined || amount === null || amount === 0) return "0 MVC";
        return (amount / 1e12).toFixed(1) + " MVC";
    }

    function formatMVCFull(amount) {
        if (amount === undefined || amount === null) return "—";
        return (amount / 1e12).toFixed(4) + " MVC";
    }

    function tagLabel(tag) {
        switch (tag) {
            case 0xB0: return qsTr("Treasury Transfer");
            case 0xB1: return qsTr("Add Signer");
            case 0xB2: return qsTr("Remove Signer");
            case 0xC0: return qsTr("Network Fund Transfer");
            default: return "0x" + tag.toString(16).toUpperCase();
        }
    }

    function tagColor(tag) {
        switch (tag) {
            case 0xB0: return "#88CCFF";
            case 0xB1: return "#FFD700";
            case 0xB2: return "#FF6B6B";
            case 0xC0: return "#88DDA8";
            default: return "#888888";
        }
    }

    function proposalStatusLabel(s) {
        switch (s) {
            case 0: return qsTr("Pending");
            case 1: return qsTr("Approved");
            case 2: return qsTr("Rejected");
            case 3: return qsTr("Expired");
            default: return qsTr("Unknown");
        }
    }

    function timeAgo(ts) {
        if (!ts || ts === 0) return "—";
        var now = Math.floor(Date.now() / 1000);
        var diff = now - ts;
        if (diff < 60) return diff + "s ago";
        if (diff < 3600) return Math.floor(diff/60) + "m ago";
        if (diff < 86400) return Math.floor(diff/3600) + "h ago";
        return Math.floor(diff/86400) + "d ago";
    }

    property string connectionError: ""
    property bool isLoading: true

    Connections {
        target: mevatrustManager
        onErrorOccurred: {
            connectionError = error;
            isLoading = false;
        }
        onNetworkStatsReceived: {
            poolStats = result;
        }
        onPoolDistributionHistoryReceived: {
            if (result && result.entries) {
                distributions = result.entries;
            }
        }
        onRecentBlocksReceived: {
            if (result && result.blocks) {
                recentBlocks = result.blocks;
            }
            if (result && result.known_height) {
                knownHeight = result.known_height;
            }
        }
        onTreasuryStatusReceived: {
            treasuryStatus = result;
        }
        onNetworkFundStatusReceived: {
            netFundStatus = result;
        }
        onGovernanceActivityReceived: {
            if (result && result.entries) {
                govActivity = result.entries;
            }
        }
        onProposerStatusReceived: {
            proposerStatus = result;
        }
        onNodePubkeyReceived: {
            if (result && result.node_pubkey) {
                nodePubkey = result.node_pubkey;
            }
        }
        onCircleProposalListReceived: {
            if (result && result.proposals) {
                proposalList = result.proposals;
            }
        }
        onCircleProposalVotesReceived: {
            if (result && result.votes) {
                proposalVotes = result.votes;
            }
        }
    }

    ColumnLayout {
        id: mainColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 16

        // ── Header ──
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            RowLayout {
                Layout.fillWidth: true
                MevaCoinComponents.Label {
                    fontSize: mobileMode ? 20 : 28
                    text: qsTr("Governance Explorer") + translationManager.emptyString
                    color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Refresh") + translationManager.emptyString
                    onClicked: refresh()
                    small: true
                    Layout.alignment: Qt.AlignRight
                }
            }
            MevaCoinComponents.TextPlain {
                font.pixelSize: 13
                text: qsTr("Real-time view of MevaTrust governance: pool distributions, block activity, and chain data.") + translationManager.emptyString
                color: MevaCoinComponents.Style.blackTheme ? "#AAAAAA" : "#555555"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            MevaCoinComponents.TextPlain {
                visible: connectionError !== ""
                text: qsTr("⚠ Connection issue: ") + connectionError + translationManager.emptyString
                font.pixelSize: 11
                color: "#FF6B6B"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // ── Summary Cards Row ──
        GridLayout {
            columns: mobileMode ? 2 : 4
            columnSpacing: 12
            rowSpacing: mobileMode ? 12 : 0
            Layout.fillWidth: true

            // Pool Balance
            Rectangle {
                Layout.fillWidth: true
                height: 110
                radius: 12
                color: MevaCoinComponents.Style.blackTheme ? "#2A2A3A" : "#FFFFFF"
                border.width: 1
                border.color: MevaCoinComponents.Style.blackTheme ? "#3A3A4A" : "#E0E0E0"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 4

                    MevaCoinComponents.TextPlain {
                        text: qsTr("Pool Balance") + translationManager.emptyString
                        font.pixelSize: 12
                        color: "#888888"
                    }
                    Item { height: 4; width: 1 }
                    MevaCoinComponents.TextPlain {
                        text: (poolStats && poolStats.pool_balance !== undefined)
                              ? (poolStats.pool_balance / 1e12).toFixed(1) + " MVC"
                              : "— MVC"
                        font.pixelSize: 26
                        font.bold: true
                        color: MevaCoinComponents.Style.orange
                    }
                    MevaCoinComponents.TextPlain {
                        text: (poolStats && poolStats.total_distributed !== undefined)
                              ? qsTr("Distributed: ") + (poolStats.total_distributed / 1e12).toFixed(1) + " MVC"
                              : ""
                        font.pixelSize: 11
                        color: "#888888"
                    }
                }
            }

            // Treasury
            Rectangle {
                Layout.fillWidth: true
                height: 110
                radius: 12
                color: MevaCoinComponents.Style.blackTheme ? "#2A2A3A" : "#FFFFFF"
                border.width: 1
                border.color: MevaCoinComponents.Style.blackTheme ? "#3A3A4A" : "#E0E0E0"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 4

                    MevaCoinComponents.TextPlain {
                        text: qsTr("Treasury") + translationManager.emptyString
                        font.pixelSize: 12
                        color: "#888888"
                    }
                    Item { height: 4; width: 1 }
                    MevaCoinComponents.TextPlain {
                        text: formatMVC(treasuryStatus.balance)
                        font.pixelSize: 26
                        font.bold: true
                        color: MevaCoinComponents.Style.blackTheme ? "#88CCFF" : "#2A6B9E"
                    }
                    MevaCoinComponents.TextPlain {
                        text: treasuryStatus.signer_count !== undefined
                              ? treasuryStatus.signer_count + qsTr("-of-") + treasuryStatus.threshold + qsTr(" governance signers")
                              : qsTr("2-of-3 governance signers")
                        font.pixelSize: 11
                        color: "#888888"
                    }
                }
            }

            // Network Fund
            Rectangle {
                Layout.fillWidth: true
                height: 110
                radius: 12
                color: MevaCoinComponents.Style.blackTheme ? "#2A2A3A" : "#FFFFFF"
                border.width: 1
                border.color: MevaCoinComponents.Style.blackTheme ? "#3A3A4A" : "#E0E0E0"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 4

                    MevaCoinComponents.TextPlain {
                        text: qsTr("Network Fund") + translationManager.emptyString
                        font.pixelSize: 12
                        color: "#888888"
                    }
                    Item { height: 4; width: 1 }
                    MevaCoinComponents.TextPlain {
                        text: formatMVC(netFundStatus.balance)
                        font.pixelSize: 26
                        font.bold: true
                        color: MevaCoinComponents.Style.blackTheme ? "#88DDA8" : "#2E8B57"
                    }
                    MevaCoinComponents.TextPlain {
                        text: netFundStatus.window_total !== undefined
                              ? qsTr("Spent: ") + formatMVC(netFundStatus.window_total)
                              : qsTr("10k MVC / 30 day limit")
                        font.pixelSize: 11
                        color: "#888888"
                    }
                }
            }

            // Active Nodes
            Rectangle {
                Layout.fillWidth: true
                height: 110
                radius: 12
                color: MevaCoinComponents.Style.blackTheme ? "#2A2A3A" : "#FFFFFF"
                border.width: 1
                border.color: MevaCoinComponents.Style.blackTheme ? "#3A3A4A" : "#E0E0E0"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 4

                    MevaCoinComponents.TextPlain {
                        text: qsTr("Active Nodes") + translationManager.emptyString
                        font.pixelSize: 12
                        color: "#888888"
                    }
                    Item { height: 4; width: 1 }
                    MevaCoinComponents.TextPlain {
                        text: (poolStats && poolStats.active_nodes !== undefined)
                              ? poolStats.active_nodes
                              : "—"
                        font.pixelSize: 26
                        font.bold: true
                        color: MevaCoinComponents.Style.blackTheme ? "#FFD700" : "#B8860B"
                    }
                    MevaCoinComponents.TextPlain {
                        text: qsTr("Registered nodes") + translationManager.emptyString
                        font.pixelSize: 11
                        color: "#888888"
                    }
                }
            }
        }

        // ── Distribution Countdown ──
        Rectangle {
            Layout.fillWidth: true
            height: mobileMode ? 180 : 80
            radius: 12
            color: MevaCoinComponents.Style.blackTheme ? "#1E2A3A" : "#EBF4FF"
            border.width: 1
            border.color: MevaCoinComponents.Style.blackTheme ? "#2A3A4A" : "#CCDDFF"

            GridLayout {
                anchors.fill: parent
                anchors.margins: 20
                columns: mobileMode ? 1 : 3
                columnSpacing: 24
                rowSpacing: 12

                ColumnLayout {
                    spacing: 2
                    Layout.alignment: Qt.AlignVCenter

                    MevaCoinComponents.TextPlain {
                        text: qsTr("Next Distribution") + translationManager.emptyString
                        font.pixelSize: 11
                        color: "#888888"
                    }
                    MevaCoinComponents.TextPlain {
                        text: {
                            if (!poolStats || poolStats.last_distribution_height === undefined)
                                return qsTr("—") + translationManager.emptyString;
                            var period = poolStats.distribution_period || 240;
                            var since = (poolStats.last_distribution_height > 0)
                                ? knownHeight - poolStats.last_distribution_height : 0;
                            if (since < 0) since = 0;
                            var remaining = period - since;
                            if (remaining <= 0) return qsTr("Due now") + translationManager.emptyString;
                            var mins = Math.ceil(remaining * 2);
                            if (mins < 120) return remaining + " blocks (~" + mins + " min)";
                            var hrs = Math.floor(mins / 60);
                            mins = mins % 60;
                            return remaining + " blocks (~" + hrs + "h " + mins + "m)";
                        }
                        font.pixelSize: 18
                        font.bold: true
                        color: MevaCoinComponents.Style.blackTheme ? "#FFD700" : "#B8860B"
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true

                    MevaCoinComponents.TextPlain {
                        text: qsTr("Current Epoch") + translationManager.emptyString
                        font.pixelSize: 11
                        color: "#888888"
                    }
                    MevaCoinComponents.TextPlain {
                        text: {
                            if (!poolStats || poolStats.last_distribution_height === undefined)
                                return qsTr("—") + translationManager.emptyString;
                            var period = poolStats.distribution_period || 240;
                            var since = (poolStats.last_distribution_height > 0)
                                ? knownHeight - poolStats.last_distribution_height : 0;
                            if (since < 0) since = 0;
                            return since + " / " + period + " blocks";
                        }
                        font.pixelSize: 14
                        color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
                    }
                    ProgressBar {
                        from: 0
                        to: poolStats.distribution_period || 240
                        value: {
                            if (!poolStats || poolStats.last_distribution_height === undefined) return 0;
                            var period = poolStats.distribution_period || 240;
                            var since = (poolStats.last_distribution_height > 0)
                                ? knownHeight - poolStats.last_distribution_height : 0;
                            if (since < 0) since = 0;
                            return since;
                        }
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        background: Rectangle {
                            radius: 3
                            color: MevaCoinComponents.Style.blackTheme ? "#333344" : "#DDDDDD"
                        }
                        contentItem: Rectangle {
                            radius: 3
                            color: MevaCoinComponents.Style.orange
                        }
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.alignment: Qt.AlignVCenter

                    MevaCoinComponents.TextPlain {
                        text: qsTr("Last Distribution") + translationManager.emptyString
                        font.pixelSize: 11
                        color: "#888888"
                    }
                    MevaCoinComponents.TextPlain {
                        text: distributions.length > 0
                              ? (distributions[0].amount / 1e12).toFixed(1) + " MVC to " + distributions[0].node_count + " nodes"
                              : qsTr("—") + translationManager.emptyString
                        font.pixelSize: 14
                        color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
                    }
                    MevaCoinComponents.TextPlain {
                        text: distributions.length > 0
                              ? qsTr("at block ") + distributions[0].height.toLocaleString()
                              : ""
                        font.pixelSize: 11
                        color: "#888888"
                    }
                }
            }
        }

        // ── Tab Section ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 360
            radius: 12
            color: MevaCoinComponents.Style.blackTheme ? "#1E1E2E" : "#F8F8FA"
            border.width: 1
            border.color: MevaCoinComponents.Style.blackTheme ? "#2E2E3E" : "#E0E0E0"
            clip: true

            property int currentTab: 0
            property var tabs: [
                qsTr("Distributions"),
                qsTr("Recent Blocks"),
                qsTr("Governance Activity"),
                qsTr("Net Fund Spends")
            ]

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Tab bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        spacing: 0

                        Repeater {
                            model: parent.parent.tabs
                            delegate: Rectangle {
                                height: 44
                                Layout.fillWidth: true
                                color: "transparent"

                                MevaCoinComponents.TextPlain {
                                    anchors.centerIn: parent
                                    text: modelData + translationManager.emptyString
                                    font.pixelSize: mobileMode ? 11 : 13
                                    font.bold: parent.parent.parent.currentTab === index
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                    color: parent.parent.parent.currentTab === index
                                           ? MevaCoinComponents.Style.orange
                                           : (MevaCoinComponents.Style.blackTheme ? "#AAAAAA" : "#555555")
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 2
                                    color: parent.parent.parent.currentTab === index
                                           ? MevaCoinComponents.Style.orange
                                           : "transparent"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: parent.parent.parent.currentTab = index
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: MevaCoinComponents.Style.blackTheme ? "#333344" : "#DDDDDD"
                }

                // Tab content
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Tab 0: Distributions
                    ListView {
                        visible: parent.parent.currentTab === 0
                        anchors.fill: parent
                        anchors.margins: 8
                        clip: true
                        model: distributions
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 44
                            color: index % 2 === 0 ? "transparent" : (MevaCoinComponents.Style.blackTheme ? "#252535" : "#F0F0F2")
                            radius: 6

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 8

                                MevaCoinComponents.TextPlain {
                                    text: qsTr("Block #") + modelData.height.toLocaleString()
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
                                    Layout.preferredWidth: 100
                                }
                                MevaCoinComponents.TextPlain {
                                    text: (modelData.amount / 1e12).toFixed(1) + " MVC"
                                    font.pixelSize: 13
                                    color: MevaCoinComponents.Style.orange
                                    Layout.preferredWidth: 120
                                }
                                MevaCoinComponents.TextPlain {
                                    text: modelData.node_count + qsTr(" nodes")
                                    font.pixelSize: 12
                                    color: "#888888"
                                    Layout.preferredWidth: 80
                                }
                                Item { Layout.fillWidth: true }
                                MevaCoinComponents.TextPlain {
                                    text: timeAgo(modelData.timestamp)
                                    font.pixelSize: 11
                                    color: "#888888"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    currentDist = modelData;
                                    distributionDialog.open();
                                }
                            }
                        }
                    }

                    // Tab 1: Recent Blocks
                    ListView {
                        visible: parent.parent.currentTab === 1
                        anchors.fill: parent
                        anchors.margins: 8
                        clip: true
                        model: recentBlocks
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 44
                            color: index % 2 === 0 ? "transparent" : (MevaCoinComponents.Style.blackTheme ? "#252535" : "#F0F0F2")
                            radius: 6

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 8

                                MevaCoinComponents.TextPlain {
                                    text: modelData.height.toLocaleString()
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
                                    Layout.preferredWidth: 70
                                }
                                MevaCoinComponents.TextPlain {
                                    text: modelData.hash.length > 12 ? modelData.hash.substring(0, 8) + "..." : modelData.hash
                                    font.pixelSize: 12
                                    color: "#888888"
                                    font.family: "monospace"
                                    Layout.preferredWidth: 100
                                }
                                MevaCoinComponents.TextPlain {
                                    text: modelData.tx_count + " tx"
                                    font.pixelSize: 12
                                    color: "#888888"
                                    Layout.preferredWidth: 60
                                }
                                MevaCoinComponents.TextPlain {
                                    text: (modelData.reward / 1e12).toFixed(3) + " MVC"
                                    font.pixelSize: 12
                                    color: MevaCoinComponents.Style.orange
                                    Layout.preferredWidth: 80
                                }
                                Item { Layout.fillWidth: true }
                                MevaCoinComponents.TextPlain {
                                    text: timeAgo(modelData.timestamp)
                                    font.pixelSize: 11
                                    color: "#888888"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    currentBlock = modelData;
                                    blockDialog.open();
                                }
                            }
                        }
                    }

                    // Tab 2: Governance Activity
                    ListView {
                        visible: parent.parent.currentTab === 2
                        anchors.fill: parent
                        anchors.margins: 8
                        clip: true
                        model: govActivity
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 44
                            color: index % 2 === 0 ? "transparent" : (MevaCoinComponents.Style.blackTheme ? "#252535" : "#F0F0F2")
                            radius: 6

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 8

                                MevaCoinComponents.TextPlain {
                                    text: modelData.height ? modelData.height.toLocaleString() : "—"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
                                    Layout.preferredWidth: 70
                                }
                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: tagColor(modelData.tag)
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                MevaCoinComponents.TextPlain {
                                    text: tagLabel(modelData.tag)
                                    font.pixelSize: 12
                                    color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
                                    Layout.preferredWidth: 120
                                }
                                MevaCoinComponents.TextPlain {
                                    text: modelData.amount ? formatMVC(modelData.amount) : ""
                                    font.pixelSize: 12
                                    color: MevaCoinComponents.Style.orange
                                    Layout.preferredWidth: 80
                                }
                                MevaCoinComponents.TextPlain {
                                    text: modelData.recipient ? modelData.recipient.substring(0, 8) + "..." : ""
                                    font.pixelSize: 11
                                    font.family: "monospace"
                                    color: "#888888"
                                    Layout.preferredWidth: 70
                                }
                                Item { Layout.fillWidth: true }
                                MevaCoinComponents.TextPlain {
                                    text: timeAgo(modelData.timestamp)
                                    font.pixelSize: 11
                                    color: "#888888"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }

                    // Tab 3: Net Fund Spends
                    ListView {
                        visible: parent.parent.currentTab === 3
                        anchors.fill: parent
                        anchors.margins: 8
                        clip: true
                        model: netFundStatus.recent_spends || []
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 36
                            color: index % 2 === 0 ? "transparent" : (MevaCoinComponents.Style.blackTheme ? "#252535" : "#F0F0F2")
                            radius: 4

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 8

                                MevaCoinComponents.TextPlain {
                                    text: qsTr("Block #") + (modelData.height ? modelData.height.toLocaleString() : "—")
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
                                    Layout.preferredWidth: 100
                                }
                                MevaCoinComponents.TextPlain {
                                    text: modelData.amount ? formatMVC(modelData.amount) : "—"
                                    font.pixelSize: 12
                                    color: MevaCoinComponents.Style.orange
                                    Layout.preferredWidth: 100
                                }
                                Item { Layout.fillWidth: true }
                                MevaCoinComponents.TextPlain {
                                    text: qsTr("Network Fund Spend")
                                    font.pixelSize: 11
                                    color: "#888888"
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Proposer Set Section ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: proposerStatus.has_proposer_keys ? 80 : (proposerStatus.status ? 72 : 72)
            radius: 12
            color: MevaCoinComponents.Style.blackTheme ? "#1E1E2E" : "#F8F8FA"
            border.width: 1
            border.color: MevaCoinComponents.Style.blackTheme ? "#2E2E3E" : "#E0E0E0"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: mobileMode ? 8 : 16

                    MevaCoinComponents.TextPlain {
                        text: qsTr("Proposer Set") + translationManager.emptyString
                        font.pixelSize: 13
                        font.bold: true
                        color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
                    }

                    Repeater {
                        model: proposerStatus.proposers || []
                        delegate: Rectangle {
                            width: mobileMode ? 60 : 80
                            height: 28
                            radius: 14
                            color: modelData.is_me ? "#4CAF50" : (modelData.active ? "#888888" : (MevaCoinComponents.Style.blackTheme ? "#444444" : "#DDDDDD"))

                            MevaCoinComponents.TextPlain {
                                anchors.centerIn: parent
                                text: "P" + (modelData.index + 1) + (modelData.is_me ? qsTr(" ★") : "")
                                font.pixelSize: 11
                                font.bold: true
                                color: modelData.is_me ? "white" : (MevaCoinComponents.Style.blackTheme ? "#CCCCCC" : "#555555")
                            }

                            MevaCoinComponents.Tooltip {
                                text: modelData.is_me ? qsTr("This node (active)") : (modelData.active ? qsTr("Active") : qsTr("Standby"))
                                visible: parent.containsMouse
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    MevaCoinComponents.TextPlain {
                        text: proposerStatus.threshold !== undefined
                              ? qsTr("Threshold: ") + proposerStatus.threshold + qsTr(" of ") + (proposerStatus.proposers ? proposerStatus.proposers.length : "?")
                              : qsTr("Threshold: 3 of 5")
                        font.pixelSize: 12
                        color: "#888888"
                    }
                }

                // Placeholder when no proposers
                MevaCoinComponents.TextPlain {
                    visible: (!proposerStatus.proposers || proposerStatus.proposers.length === 0) && proposerStatus.status !== undefined
                    text: qsTr("No proposer data available. Ensure the daemon has proposer keys configured.") + translationManager.emptyString
                    font.pixelSize: 11
                    color: "#888888"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                // Node pubkey row
                MevaCoinComponents.TextPlain {
                    visible: nodePubkey !== ""
                    text: qsTr("Node Pubkey: ") + nodePubkey
                    font.pixelSize: 10
                    font.family: "monospace"
                    color: "#888888"
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }
            }
        }

        // ── Circle Proposals Section ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 240
            radius: 12
            color: MevaCoinComponents.Style.blackTheme ? "#1E1E2E" : "#F8F8FA"
            border.width: 1
            border.color: MevaCoinComponents.Style.blackTheme ? "#2E2E3E" : "#E0E0E0"
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        MevaCoinComponents.TextPlain {
                            text: qsTr("Circle Proposals") + translationManager.emptyString
                            font.pixelSize: 14
                            font.bold: true
                            color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
                        }
                        Item { Layout.fillWidth: true }
                        MevaCoinComponents.LineEdit {
                            id: circleIdInput
                            placeholderText: qsTr("Circle ID (hex)") + translationManager.emptyString
                            Layout.preferredWidth: mobileMode ? 120 : 260
                            Layout.preferredHeight: 28
                            fontSize: 11
                        }
                        MevaCoinComponents.StandardButton {
                            text: qsTr("Load") + translationManager.emptyString
                            onClicked: {
                                if (circleIdInput.text.length > 0) {
                                    mevatrustManager.circleProposalList(circleIdInput.text);
                                }
                            }
                            small: true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: MevaCoinComponents.Style.blackTheme ? "#333344" : "#DDDDDD"
                }

                // Proposal list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    anchors.margins: 8
                    clip: true
                    model: proposalList
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 36
                        color: index % 2 === 0 ? "transparent" : (MevaCoinComponents.Style.blackTheme ? "#252535" : "#F0F0F2")
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            MevaCoinComponents.TextPlain {
                                text: modelData.proposal_id ? modelData.proposal_id.substring(0, 8) + "..." : "—"
                                font.pixelSize: 11
                                font.family: "monospace"
                                color: "#888888"
                                Layout.preferredWidth: 70
                            }
                            MevaCoinComponents.TextPlain {
                                text: modelData.target_pk ? modelData.target_pk.substring(0, 8) + "..." : "—"
                                font.pixelSize: 11
                                color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
                                Layout.preferredWidth: 70
                            }
                            MevaCoinComponents.TextPlain {
                                text: modelData.yes_count + "/" + modelData.no_count
                                font.pixelSize: 11
                                color: modelData.yes_count > modelData.no_count ? "#4CAF50" : "#FF6B6B"
                                Layout.preferredWidth: 40
                            }
                            MevaCoinComponents.TextPlain {
                                text: proposalStatusLabel(modelData.status)
                                font.pixelSize: 11
                                color: "#888888"
                                Layout.preferredWidth: 60
                            }
                            Item { Layout.fillWidth: true }
                            MevaCoinComponents.TextPlain {
                                text: qsTr("Block #") + (modelData.created_height ? modelData.created_height.toLocaleString() : "—")
                                font.pixelSize: 11
                                color: "#888888"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                selectedProposalId = modelData.proposal_id;
                                mevatrustManager.circleProposalVotes(selectedProposalId);
                            }
                        }
                    }

                    // Placeholder when no proposals loaded
                    Rectangle {
                        anchors.fill: parent
                        visible: proposalList.length === 0
                        color: "transparent"

                        MevaCoinComponents.TextPlain {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            text: proposalList.length === 0
                                  ? qsTr("Enter a Circle ID (hex) above and click Load to view proposals.") + translationManager.emptyString
                                  : ""
                            font.pixelSize: 12
                            color: "#888888"
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }

        // ── Circle Proposal Votes Dialog ──
        MevaCoinComponents.StandardDialog {
            id: votesDialog
            title: qsTr("Proposal Votes") + translationManager.emptyString
            height: 300
            onAccepted: close()
            onRejected: close()

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10

                MevaCoinComponents.TextPlain {
                    text: qsTr("Proposal: ") + selectedProposalId
                    font.pixelSize: 11
                    font.family: "monospace"
                    color: "#888888"
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: proposalVotes
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 32
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            spacing: 8

                            MevaCoinComponents.TextPlain {
                                text: modelData.voter_pk ? modelData.voter_pk.substring(0, 12) + "..." : "—"
                                font.pixelSize: 11
                                font.family: "monospace"
                                color: "#888888"
                            }
                            MevaCoinComponents.TextPlain {
                                text: modelData.vote_yes ? qsTr("YES") : qsTr("NO")
                                font.pixelSize: 12
                                font.bold: true
                                color: modelData.vote_yes ? "#4CAF50" : "#FF6B6B"
                            }
                            Item { Layout.fillWidth: true }
                            MevaCoinComponents.TextPlain {
                                text: qsTr("Block #") + (modelData.height ? modelData.height.toLocaleString() : "—")
                                font.pixelSize: 11
                                color: "#888888"
                            }
                        }
                    }
                }
            }
        }

        // ── Bottom spacer ──
        Item { height: 20; width: 1 }
    }

    // ── Detail Dialogs ──

    // Distribution Detail Dialog
    MevaCoinComponents.StandardDialog {
        id: distributionDialog
        title: qsTr("Distribution Detail") + translationManager.emptyString
        height: 300
        onAccepted: close()
        onRejected: close()

        property var distData: ({})

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            MevaCoinComponents.TextPlain {
                text: qsTr("Block Height:") + " " + (distributionDialog.distData.height ? distributionDialog.distData.height.toLocaleString() : "—")
                font.pixelSize: 13; color: "#888888"
            }
            MevaCoinComponents.TextPlain {
                text: qsTr("Amount:") + " " + (distributionDialog.distData.amount ? (distributionDialog.distData.amount / 1e12).toFixed(1) + " MVC" : "—")
                font.pixelSize: 18; font.bold: true; color: MevaCoinComponents.Style.orange
            }
            MevaCoinComponents.TextPlain {
                text: qsTr("Nodes:") + " " + (distributionDialog.distData.node_count || "—")
                font.pixelSize: 13; color: "#888888"
            }
            MevaCoinComponents.TextPlain {
                text: qsTr("FROST Signature:") + " 3 of 5 proposers"
                font.pixelSize: 13; color: "#888888"
            }
            MevaCoinComponents.TextPlain {
                text: qsTr("Tag:") + " 0xAA (pool_distribution)"
                font.pixelSize: 13; color: "#888888"
            }
        }
    }

    // Block Detail Dialog
    MevaCoinComponents.StandardDialog {
        id: blockDialog
        title: qsTr("Block Detail") + translationManager.emptyString
        height: 340
        onAccepted: close()
        onRejected: close()

        property var blockData: ({})

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            MevaCoinComponents.TextPlain {
                text: qsTr("Height:") + " " + (blockDialog.blockData.height ? blockDialog.blockData.height.toLocaleString() : "—")
                font.pixelSize: 13; font.bold: true; color: MevaCoinComponents.Style.blackTheme ? "white" : "black"
            }
            MevaCoinComponents.TextPlain {
                text: qsTr("Hash:") + " " + (blockDialog.blockData.hash || "—")
                font.pixelSize: 12; font.family: "monospace"; color: "#888888"
            }
            MevaCoinComponents.TextPlain {
                text: qsTr("Timestamp:") + " " + (blockDialog.blockData.timestamp ? new Date(blockDialog.blockData.timestamp * 1000).toUTCString() : "—")
                font.pixelSize: 13; color: "#888888"
            }
            MevaCoinComponents.TextPlain {
                text: qsTr("Transactions:") + " " + (blockDialog.blockData.tx_count || "—")
                font.pixelSize: 13; color: "#888888"
            }
            MevaCoinComponents.TextPlain {
                text: qsTr("Reward:") + " " + (blockDialog.blockData.reward ? (blockDialog.blockData.reward / 1e12).toFixed(3) + " MVC" : "—")
                font.pixelSize: 13; color: MevaCoinComponents.Style.orange
            }
            MevaCoinComponents.TextPlain {
                text: qsTr("Pool Contribution:") + " " + (blockDialog.blockData.reward ? ((blockDialog.blockData.reward * 0.03 / 1e12).toFixed(3)) + " MVC (3%)" : "—")
                font.pixelSize: 13; color: "#888888"
            }
            MevaCoinComponents.TextPlain {
                text: qsTr("Size:") + " —"
                font.pixelSize: 13; color: "#888888"
            }
        }
    }

    property var currentDist: ({})
    property var currentBlock: ({})

    onCurrentDistChanged: {
        distributionDialog.distData = currentDist;
    }
    onCurrentBlockChanged: {
        blockDialog.blockData = currentBlock;
    }
}
