import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import "../components" as MevaCoinComponents

Rectangle {
    id: mevatrustPage
    color: "transparent"
    property int myHeight: mainLayout.implicitHeight + 20
    property var nodeData: ({})

    ColumnLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20

        MevaCoinComponents.Label {
            text: qsTr("MevaTrust Network") + translationManager.emptyString
            fontSize: 32
            fontBold: true
        }

        MevaCoinComponents.Label {
            text: qsTr("Node reputation & badge system for long-lived network participants") + translationManager.emptyString
            fontSize: 14
            color: MevaCoinComponents.Style.defaultFontColor
            opacity: 0.7
        }

        Item { height: 10; width: 1 }

        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            MevaCoinComponents.StandardButton {
                id: lookupBtn
                text: qsTr("Node Lookup") + translationManager.emptyString
                onClicked: {
                    lookupNodeDialog.open();
                }
            }

            MevaCoinComponents.StandardButton {
                text: qsTr("Network Stats") + translationManager.emptyString
                onClicked: {
                    networkStatsSheet.open();
                }
            }

            MevaCoinComponents.StandardButton {
                text: qsTr("Badge Gallery") + translationManager.emptyString
                onClicked: {
                    badgeGallerySheet.open();
                }
            }

            MevaCoinComponents.StandardButton {
                text: qsTr("Top Nodes") + translationManager.emptyString
                onClicked: {
                    topNodesSheet.open();
                }
            }
        }

        Item { height: 20; width: 1 }

        MevaCoinComponents.Label {
            text: qsTr("Network Overview") + translationManager.emptyString
            fontSize: 20
            fontBold: true
        }

        Item { height: 5; width: 1 }

        Rectangle {
            Layout.fillWidth: true
            height: 100
            color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
            radius: 8
            border.color: MevaCoinComponents.Style.dividerColor
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 20

                ColumnLayout {
                    Layout.alignment: Qt.AlignCenter
                    MevaCoinComponents.Label {
                        text: qsTr("Active Nodes") + translationManager.emptyString
                        fontSize: 11
                        opacity: 0.6
                    }
                    MevaCoinComponents.Label {
                        id: activeNodesCount
                        text: "--"
                        fontSize: 24
                        fontBold: true
                        color: MevaCoinComponents.Style.wookeyGreen
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignCenter
                    MevaCoinComponents.Label {
                        text: qsTr("Pool Balance") + translationManager.emptyString
                        fontSize: 11
                        opacity: 0.6
                    }
                    MevaCoinComponents.Label {
                        id: poolBalanceLabel
                        text: "--"
                        fontSize: 24
                        fontBold: true
                        color: MevaCoinComponents.Style.orange
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignCenter
                    MevaCoinComponents.Label {
                        text: qsTr("Total Rewarded") + translationManager.emptyString
                        fontSize: 11
                        opacity: 0.6
                    }
                    MevaCoinComponents.Label {
                        id: totalRewardedLabel
                        text: "--"
                        fontSize: 24
                        fontBold: true
                        color: MevaCoinComponents.Style.green
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignCenter
                    MevaCoinComponents.Label {
                        text: qsTr("Avg Score") + translationManager.emptyString
                        fontSize: 11
                        opacity: 0.6
                    }
                    MevaCoinComponents.Label {
                        id: avgScoreLabel
                        text: "--"
                        fontSize: 24
                        fontBold: true
                    }
                }
            }
        }

        Item { height: 15; width: 1 }

        MevaCoinComponents.Label {
            text: qsTr("Recent Badge Awards") + translationManager.emptyString
            fontSize: 20
            fontBold: true
        }

        Item { height: 5; width: 1 }

        Rectangle {
            Layout.fillWidth: true
            Layout.minimumHeight: 60
            color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
            radius: 8
            border.color: MevaCoinComponents.Style.dividerColor
            border.width: 1
            visible: recentAwardsRepeater.count > 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                Repeater {
                    id: recentAwardsRepeater
                    model: ListModel {}
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Rectangle {
                            width: 12; height: 12; radius: 6
                            color: badgeColor
                        }
                        MevaCoinComponents.Label {
                            text: badgeName
                            fontSize: 13
                            Layout.fillWidth: true
                        }
                        MevaCoinComponents.Label {
                            text: nodeId
                            fontSize: 11
                            opacity: 0.6
                            fontFamily: "Courier"
                        }
                    }
                }
            }
        }

        MevaCoinComponents.Label {
            text: qsTr("No recent badge awards yet") + translationManager.emptyString
            fontSize: 13
            opacity: 0.5
            visible: recentAwardsRepeater.count === 0
        }
    }

    function onPageCompleted() {
        mevatrustManager.getNetworkStats();
        mevatrustManager.getTopNodes(10);
    }

    Connections {
        target: mevatrustManager
        onNetworkStatsReceived: {
            var data = stats;
            activeNodesCount.text = (data.active_nodes || data.active_nodes === 0) ? data.active_nodes : "--";
            poolBalanceLabel.text = stats.pool_balance ? walletManager.displayAmount(stats.pool_balance) : "--";
            totalRewardedLabel.text = stats.total_distributed ? walletManager.displayAmount(stats.total_distributed) : "--";
            avgScoreLabel.text = stats.average_score ? parseFloat(stats.average_score).toFixed(2) : "--";
        }
        onTopNodesReceived: {
            recentAwardsRepeater.model.clear();
            var nodes = nodes.nodes || [];
            for (var i = 0; i < Math.min(nodes.length, 5); i++) {
                var n = nodes[i];
                recentAwardsRepeater.model.append({
                    badgeName: n.badge_types && n.badge_types.length > 0 ? n.badge_types[0] : "Active",
                    nodeId: n.node_id ? n.node_id.toString().substring(0, 16) + "..." : "--",
                    badgeColor: n.badge_count > 3 ? MevaCoinComponents.Style.wookeyGreen :
                                n.badge_count > 1 ? MevaCoinComponents.Style.orange :
                                MevaCoinComponents.Style.green
                });
            }
        }
        onErrorOccurred: {
            console.log("Mevatrust error:", error);
        }
    }

    MevaCoinComponents.StandardDialog {
        id: lookupNodeDialog
        title: qsTr("Node Lookup") + translationManager.emptyString
        height: 200
        width: 400

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            MevaCoinComponents.Label {
                text: qsTr("Enter Node ID (64 hex chars):") + translationManager.emptyString
                fontSize: 13
            }

            MevaCoinComponents.LineEdit {
                id: nodeIdInput
                Layout.fillWidth: true
                placeholderText: qsTr("Paste node ID here") + translationManager.emptyString
            }

            Item { height: 5; width: 1 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Item { Layout.fillWidth: true }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Cancel") + translationManager.emptyString
                    onClicked: lookupNodeDialog.close()
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Search") + translationManager.emptyString
                    primary: true
                    enabled: nodeIdInput.text.length >= 64
                    onClicked: {
                        lookupNodeDialog.close();
                        nodeDetailsSheet.nodeId = nodeIdInput.text.trim();
                        nodeDetailsSheet.open();
                        mevatrustManager.lookupNode(nodeIdInput.text.trim());
                        mevatrustManager.getNodeBadges(nodeIdInput.text.trim());
                        mevatrustManager.getNodeUptime(nodeIdInput.text.trim());
                        mevatrustManager.getNodeScore(nodeIdInput.text.trim());
                        mevatrustManager.getNodeRewards(nodeIdInput.text.trim());
                    }
                }
            }
        }
    }

    MevaCoinComponents.StandardDialog {
        id: nodeDetailsSheet
        title: qsTr("Node Details") + translationManager.emptyString
        property string nodeId: ""
        width: 600
        height: 500

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8

            MevaCoinComponents.Label {
                text: qsTr("Node ID:") + translationManager.emptyString
                fontSize: 11; opacity: 0.6
            }
            MevaCoinComponents.Label {
                id: detailNodeId
                text: nodeDetailsSheet.nodeId
                fontSize: 12; fontFamily: "Courier"
                wrapMode: Text.Wrap
            }

            Item { height: 5; width: 1 }

            GridLayout {
                columns: 2; columnSpacing: 20; rowSpacing: 6

                MevaCoinComponents.Label { text: qsTr("Status:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: detailStatus; text: "--"; fontSize: 12; fontBold: true }

                MevaCoinComponents.Label { text: qsTr("Score:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: detailScore; text: "--"; fontSize: 12 }

                MevaCoinComponents.Label { text: qsTr("Uptime:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: detailUptime; text: "--"; fontSize: 12 }

                MevaCoinComponents.Label { text: qsTr("Uptime %:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: detailUptimePct; text: "--"; fontSize: 12 }

                MevaCoinComponents.Label { text: qsTr("Last Seen:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: detailLastSeen; text: "--"; fontSize: 12 }

                MevaCoinComponents.Label { text: qsTr("Total Rewards:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: detailRewards; text: "--"; fontSize: 12 }
            }

            Item { height: 10; width: 1 }

            MevaCoinComponents.Label {
                text: qsTr("Badges Earned") + translationManager.emptyString
                fontSize: 16; fontBold: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    id: badgeRepeater
                    model: ListModel {}
                    delegate: MevaCoinComponents.BadgeCard {
                        badgeName: model.badgeName
                        badgeDescription: model.badgeDescription
                        badgeColor: model.badgeColor
                        isEarned: model.isEarned
                        earnedHeight: model.earnedHeight
                    }
                }
            }

            MevaCoinComponents.Label {
                text: qsTr("No badges yet") + translationManager.emptyString
                fontSize: 12; opacity: 0.5
                visible: badgeRepeater.count === 0
            }
        }
    }

    MevaCoinComponents.StandardDialog {
        id: networkStatsSheet
        title: qsTr("Network Statistics") + translationManager.emptyString
        width: 500; height: 400

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 8

            GridLayout {
                columns: 2; columnSpacing: 20; rowSpacing: 6

                MevaCoinComponents.Label { text: qsTr("Active Nodes:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: nsActiveNodes; text: "--"; fontSize: 14; fontBold: true }

                MevaCoinComponents.Label { text: qsTr("Eligible Nodes:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: nsEligibleNodes; text: "--"; fontSize: 14 }

                MevaCoinComponents.Label { text: qsTr("Pool Balance:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: nsPoolBalance; text: "--"; fontSize: 14; color: MevaCoinComponents.Style.wookeyGreen }

                MevaCoinComponents.Label { text: qsTr("Total Distributed:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: nsTotalDistributed; text: "--"; fontSize: 14; color: MevaCoinComponents.Style.green }

                MevaCoinComponents.Label { text: qsTr("Avg Uptime:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: nsAvgUptime; text: "--"; fontSize: 14 }

                MevaCoinComponents.Label { text: qsTr("Avg Score:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: nsAvgScore; text: "--"; fontSize: 14 }

                MevaCoinComponents.Label { text: qsTr("Last Distribution:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: nsLastDist; text: "--"; fontSize: 12 }
            }

            Item { height: 10; width: 1 }
            MevaCoinComponents.Label {
                text: qsTr("Top Nodes") + translationManager.emptyString
                fontSize: 16; fontBold: true
            }

            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
                radius: 6; border.color: MevaCoinComponents.Style.dividerColor; border.width: 1
                clip: true

                Flickable {
                    anchors.fill: parent; anchors.margins: 8
                    contentHeight: topNodeList.implicitHeight
                    interactive: true

                    ColumnLayout {
                        id: topNodeList
                        width: parent.width
                        Repeater {
                            id: topNodesRepeater
                            model: ListModel {}
                            delegate: RowLayout {
                                Layout.fillWidth: true; spacing: 6
                                MevaCoinComponents.Label {
                                    text: (index + 1) + "."
                                    fontSize: 12; opacity: 0.6
                                }
                                MevaCoinComponents.Label {
                                    text: nodeIdShort
                                    fontSize: 11; fontFamily: "Courier"
                                }
                                Item { Layout.fillWidth: true }
                                MevaCoinComponents.Label {
                                    text: score
                                    fontSize: 12; fontBold: true
                                    color: MevaCoinComponents.Style.wookeyGreen
                                }
                                MevaCoinComponents.Label {
                                    text: badges
                                    fontSize: 11; opacity: 0.6
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    MevaCoinComponents.StandardDialog {
        id: badgeGallerySheet
        title: qsTr("Badge Gallery") + translationManager.emptyString
        width: 600; height: 500

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 8

            MevaCoinComponents.Label {
                text: qsTr("All available badges and their requirements") + translationManager.emptyString
                fontSize: 12; opacity: 0.7
            }

            Item { height: 5; width: 1 }

            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
                radius: 6; border.color: MevaCoinComponents.Style.dividerColor; border.width: 1
                clip: true

                Flickable {
                    anchors.fill: parent; anchors.margins: 8
                    contentHeight: badgesGalleryList.implicitHeight
                    interactive: true

                    Flow {
                        id: badgesGalleryList
                        width: parent.width
                        spacing: 10
                        Repeater {
                            id: badgeGalleryRepeater
                            model: ListModel {}
                            delegate: MevaCoinComponents.BadgeCard {
                                badgeName: model.badgeName
                                badgeDescription: model.badgeDescription
                                badgeColor: model.badgeColor
                                isEarned: false
                                badgeProgress: model.hasProgress ? model.progressText : ""
                            }
                        }
                    }
                }
            }
        }
    }

    MevaCoinComponents.StandardDialog {
        id: topNodesSheet
        title: qsTr("Top Nodes") + translationManager.emptyString
        width: 550; height: 450

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 8

            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
                radius: 6; border.color: MevaCoinComponents.Style.dividerColor; border.width: 1
                clip: true

                Flickable {
                    anchors.fill: parent; anchors.margins: 8
                    contentHeight: topNodesFullList.implicitHeight
                    interactive: true

                    ColumnLayout {
                        id: topNodesFullList
                        width: parent.width
                        Repeater {
                            id: topNodesFullRepeater
                            model: ListModel {}
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 40
                                color: index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.03)
                                radius: 4

                                RowLayout {
                                    anchors.fill: parent; anchors.margins: { left: 8; right: 8 }
                                    spacing: 8

                                    MevaCoinComponents.Label {
                                        text: ("#" + (index + 1))
                                        fontSize: 14; fontBold: true
                                        color: index < 3 ? MevaCoinComponents.Style.wookeyGreen : MevaCoinComponents.Style.defaultFontColor
                                        width: 30
                                    }

                                    ColumnLayout {
                                        spacing: 1
                                        MevaCoinComponents.Label {
                                            text: nodeIdShort
                                            fontSize: 12; fontFamily: "Courier"; fontBold: true
                                        }
                                        MevaCoinComponents.Label {
                                            text: walletShort
                                            fontSize: 10; opacity: 0.5; fontFamily: "Courier"
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    MevaCoinComponents.Label {
                                        text: qsTr("Score:") + translationManager.emptyString
                                        fontSize: 10; opacity: 0.5
                                    }
                                    MevaCoinComponents.Label {
                                        text: score
                                        fontSize: 14; fontBold: true
                                        color: MevaCoinComponents.Style.wookeyGreen
                                    }

                                    MevaCoinComponents.Label {
                                        text: qsTr("Badges:") + translationManager.emptyString
                                        fontSize: 10; opacity: 0.5
                                    }
                                    MevaCoinComponents.Label {
                                        text: badgeCount
                                        fontSize: 14; fontBold: true
                                        color: parseFloat(badgeCount) > 3 ? MevaCoinComponents.Style.wookeyGreen :
                                               parseFloat(badgeCount) > 1 ? MevaCoinComponents.Style.orange :
                                               MevaCoinComponents.Style.defaultFontColor
                                    }

                                    MevaCoinComponents.Label {
                                        text: qsTr("Rewards:") + translationManager.emptyString
                                        fontSize: 10; opacity: 0.5
                                    }
                                    MevaCoinComponents.Label {
                                        text: totalRewards
                                        fontSize: 12
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: mevatrustManager
        onNodeStatusReceived: {
            detailStatus.text = status.is_active ? 
                (status.is_synced ? qsTr("Active & Synced") : qsTr("Active")) + translationManager.emptyString :
                qsTr("Inactive") + translationManager.emptyString;
            detailLastSeen.text = status.last_seen ? 
                new Date(status.last_seen * 1000).toLocaleString() : "--";
            if (status.wallet_address) {
                // could show wallet
            }
        }
        onNodeScoreReceived: {
            detailScore.text = score.score ? parseFloat(score.score).toFixed(4) : "--";
        }
        onNodeUptimeReceived: {
            var hours = uptime.uptime_seconds ? (uptime.uptime_seconds / 3600).toFixed(1) : "0";
            detailUptime.text = hours + " " + qsTr("hours") + translationManager.emptyString;
            detailUptimePct.text = uptime.uptime_percentage ? parseFloat(uptime.uptime_percentage).toFixed(1) + "%" : "--";
        }
        onNodeBadgesReceived: {
            badgeRepeater.model.clear();
            var badges = badges.badges || [];
            for (var i = 0; i < badges.length; i++) {
                var b = badges[i];
                badgeRepeater.model.append({
                    badgeName: b.name || b.type_name || "Badge",
                    badgeDescription: b.description || "",
                    badgeColor: badgeColorFor(b.type_name || b.name || ""),
                    isEarned: b.earned || true,
                    earnedHeight: b.awarded_height || 0
                });
            }
        }
        onNodeRewardsReceived: {
            detailRewards.text = rewards.total_rewards ? 
                walletManager.displayAmount(rewards.total_rewards) : "0";
        }
        onNetworkStatsReceived: {
            nsActiveNodes.text = (stats.active_nodes || stats.active_nodes === 0) ? stats.active_nodes : "--";
            nsEligibleNodes.text = (stats.total_eligible_nodes || stats.total_eligible_nodes === 0) ? stats.total_eligible_nodes : "--";
            nsPoolBalance.text = stats.pool_balance ? walletManager.displayAmount(stats.pool_balance) : "--";
            nsTotalDistributed.text = stats.total_distributed ? walletManager.displayAmount(stats.total_distributed) : "--";
            nsAvgUptime.text = stats.average_uptime ? parseFloat(stats.average_uptime).toFixed(1) + "%" : "--";
            nsAvgScore.text = stats.average_score ? parseFloat(stats.average_score).toFixed(4) : "--";
            nsLastDist.text = stats.last_distribution_height ? 
                qsTr("Block") + translationManager.emptyString + " " + stats.last_distribution_height : "--";
        }
        onTopNodesReceived: {
            var data = nodes;
            topNodesRepeater.model.clear();
            topNodesFullRepeater.model.clear();
            var nodeList = data.nodes || [];
            for (var i = 0; i < nodeList.length; i++) {
                var n = nodeList[i];
                var shortId = n.node_id ? n.node_id.toString().substring(0, 12) + "..." : "--";
                var shortWallet = n.wallet_address ? n.wallet_address.toString().substring(0, 12) + "..." : "";
                var scoreStr = n.score ? parseFloat(n.score).toFixed(2) : "0";
                var badgeStr = n.badge_count ? String(n.badge_count) + " badges" : "0 badges";
                var badgesCount = n.badge_count || 0;
                var rewardsStr = n.total_rewards ? walletManager.displayAmount(n.total_rewards) : "0";

                topNodesRepeater.model.append({
                    nodeIdShort: shortId,
                    score: scoreStr,
                    badges: badgeStr
                });
                topNodesFullRepeater.model.append({
                    nodeIdShort: shortId,
                    walletShort: shortWallet,
                    score: scoreStr,
                    badgeCount: String(badgesCount),
                    totalRewards: rewardsStr
                });
            }
        }
        onBadgeRequirementsReceived: {
            badgeGalleryRepeater.model.clear();
            var badges = badges.badges || [];
            for (var i = 0; i < badges.length; i++) {
                var b = badges[i];
                badgeGalleryRepeater.model.append({
                    badgeName: b.name || b.type_name || "Badge",
                    badgeDescription: b.description || b.details || "",
                    badgeColor: badgeColorFor(b.name || b.type_name || ""),
                    hasProgress: false,
                    progressText: ""
                });
            }

            if (badgeGalleryRepeater.model.count === 0) {
                var allBadges = [
                    { name: "Active Miner", desc: "Mine at least one block", color: "#4CAF50" },
                    { name: "Full Node Operator", desc: "24/7 node operation", color: "#2196F3" },
                    { name: "Stable Node", desc: "Days of stable operation", color: "#9C27B0" },
                    { name: "Core Network Node", desc: "Exceptional reliability", color: "#FF9800" },
                    { name: "Long Uptime Node", desc: "Months of continuous uptime", color: "#F44336" },
                    { name: "Early Supporter", desc: "Registered in first period", color: "#E91E63" },
                    { name: "Network Validator", desc: "Promoted to validator", color: "#00BCD4" },
                    { name: "Bridge Node", desc: "Facilitates cross-network", color: "#795548" },
                    { name: "Privacy Guardian", desc: "Privacy-preserving node", color: "#607D8B" },
                    { name: "Relay Master", desc: "Top relay performance", color: "#CDDC39" },
                    { name: "Welcome", desc: "First badge for new registrants", color: "#FF5722" }
                ];
                for (var j = 0; j < allBadges.length; j++) {
                    var ab = allBadges[j];
                    badgeGalleryRepeater.model.append({
                        badgeName: ab.name,
                        badgeDescription: ab.desc,
                        badgeColor: ab.color,
                        hasProgress: false,
                        progressText: ""
                    });
                }
            }
        }
    }

    function badgeColorFor(name) {
        var colors = {
            "Active Miner": "#4CAF50",
            "Full Node Operator": "#2196F3",
            "Stable Node": "#9C27B0",
            "Core Network Node": "#FF9800",
            "Long Uptime Node": "#F44336",
            "Early Supporter": "#E91E63",
            "Network Validator": "#00BCD4",
            "Bridge Node": "#795548",
            "Privacy Guardian": "#607D8B",
            "Relay Master": "#CDDC39",
            "Welcome": "#FF5722"
        };
        return colors[name] || MevaCoinComponents.Style.wookeyGreen;
    }

}
