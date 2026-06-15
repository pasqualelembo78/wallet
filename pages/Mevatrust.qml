import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import "../components" as MevaCoinComponents

Rectangle {
    id: mevatrustPage
    color: "transparent"
    property int myHeight: mainLayout.implicitHeight + 20
    property string myNodeId: ""
    property var nodeData: ({})
    property var myNodeDetails: ({})
    property var myBadges: []
    property var myCircles: []
    property var myPenalties: []

    function onPageCompleted() {
        mevatrustManager.getNetworkStats();
        mevatrustManager.getTopNodes(10);
        loadMyNode();
    }

    function loadMyNode() {
        myNodeId = appWindow.persistentSettings.mevatrust_node_id || "";
        if (myNodeId.length >= 64) {
            refreshMyNode();
        }
    }

    function saveMyNode() {
        appWindow.persistentSettings.mevatrust_node_id = myNodeId;
        refreshMyNode();
    }

    function refreshMyNode() {
        if (myNodeId.length < 64) return;
        mevatrustManager.lookupNode(myNodeId);
        mevatrustManager.getNodeBadges(myNodeId);
        mevatrustManager.getNodeScore(myNodeId);
        mevatrustManager.getNodeUptime(myNodeId);
        mevatrustManager.getNodeRewards(myNodeId);
        mevatrustManager.getPenaltyHistory(myNodeId);
        mevatrustManager.getNodeIncentiveHistory(myNodeId, 5);
    }

    ColumnLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20

        MevaCoinComponents.Label {
            text: qsTr("MevaTrust Network") + translationManager.emptyString
            fontSize: mobileMode ? 24 : 32
            fontBold: true
        }

        MevaCoinComponents.Label {
            text: qsTr("Node reputation & badge system for long-lived network participants") + translationManager.emptyString
            fontSize: 14
            color: MevaCoinComponents.Style.defaultFontColor
            opacity: 0.7
        }

        Item { height: 10; width: 1 }

        Flow {
            Layout.fillWidth: true
            spacing: 10

            MevaCoinComponents.StandardButton {
                text: (myNodeId.length >= 64 ? qsTr("My Node") : qsTr("My Node")) + translationManager.emptyString
                primary: myNodeId.length >= 64
                onClicked: myNodeSheet.open()
            }
            MevaCoinComponents.StandardButton {
                text: qsTr("Node Lookup") + translationManager.emptyString
                onClicked: lookupNodeDialog.open()
            }
            MevaCoinComponents.StandardButton {
                text: qsTr("Network Stats") + translationManager.emptyString
                onClicked: networkStatsSheet.open()
            }
            MevaCoinComponents.StandardButton {
                text: qsTr("Badge Gallery") + translationManager.emptyString
                onClicked: badgeGallerySheet.open()
            }
            MevaCoinComponents.StandardButton {
                text: qsTr("Top Nodes") + translationManager.emptyString
                onClicked: topNodesSheet.open()
            }
        }

        Item { height: 20; width: 1 }

        // ── My Node Dashboard ─────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: myNodeId.length >= 64 ? myNodeDashImplicit : 60
            color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
            radius: 8
            border.color: MevaCoinComponents.Style.dividerColor
            border.width: 1
            visible: myNodeId.length >= 64

            ColumnLayout {
                id: myNodeDashLayout
                anchors.fill: parent
                anchors.margins: 15
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    MevaCoinComponents.Label {
                        text: qsTr("My Node") + translationManager.emptyString
                        fontSize: 18; fontBold: true
                    }
                    Item { Layout.fillWidth: true }
                    MevaCoinComponents.Label {
                        text: myNodeId.substring(0, 20) + "..."
                        fontSize: 11; fontFamily: "Courier"; opacity: 0.6
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: MevaCoinComponents.Style.dividerColor; opacity: 0.3 }

                GridLayout {
                    columns: mobileMode ? 2 : 4; columnSpacing: 20; rowSpacing: 6

                    ColumnLayout { Layout.alignment: Qt.AlignCenter
                        MevaCoinComponents.Label { text: qsTr("Status") + translationManager.emptyString; fontSize: 10; opacity: 0.6 }
                        MevaCoinComponents.Label { id: dashStatus; text: "--"; fontSize: 14; fontBold: true; color: MevaCoinComponents.Style.wookeyGreen }
                    }
                    ColumnLayout { Layout.alignment: Qt.AlignCenter
                        MevaCoinComponents.Label { text: qsTr("Score") + translationManager.emptyString; fontSize: 10; opacity: 0.6 }
                        MevaCoinComponents.Label { id: dashScore; text: "--"; fontSize: 14; fontBold: true }
                    }
                    ColumnLayout { Layout.alignment: Qt.AlignCenter
                        MevaCoinComponents.Label { text: qsTr("Uptime") + translationManager.emptyString; fontSize: 10; opacity: 0.6 }
                        MevaCoinComponents.Label { id: dashUptime; text: "--"; fontSize: 14; fontBold: true; color: MevaCoinComponents.Style.orange }
                    }
                    ColumnLayout { Layout.alignment: Qt.AlignCenter
                        MevaCoinComponents.Label { text: qsTr("Rewards") + translationManager.emptyString; fontSize: 10; opacity: 0.6 }
                        MevaCoinComponents.Label { id: dashRewards; text: "--"; fontSize: 14; fontBold: true; color: MevaCoinComponents.Style.green }
                    }
                    ColumnLayout { Layout.alignment: Qt.AlignCenter
                        MevaCoinComponents.Label { text: qsTr("Badges") + translationManager.emptyString; fontSize: 10; opacity: 0.6 }
                        MevaCoinComponents.Label { id: dashBadges; text: "--"; fontSize: 14; fontBold: true }
                    }
                    ColumnLayout { Layout.alignment: Qt.AlignCenter
                        MevaCoinComponents.Label { text: qsTr("Uptime %") + translationManager.emptyString; fontSize: 10; opacity: 0.6 }
                        MevaCoinComponents.Label { id: dashUptimePct; text: "--"; fontSize: 14; fontBold: true }
                    }
                    ColumnLayout { Layout.alignment: Qt.AlignCenter
                        MevaCoinComponents.Label { text: qsTr("Penalties") + translationManager.emptyString; fontSize: 10; opacity: 0.6 }
                        MevaCoinComponents.Label { id: dashPenalties; text: "--"; fontSize: 14; fontBold: true }
                    }
                    ColumnLayout { Layout.alignment: Qt.AlignCenter
                        MevaCoinComponents.Label { text: qsTr("Circles") + translationManager.emptyString; fontSize: 10; opacity: 0.6 }
                        MevaCoinComponents.Label { id: dashCircles; text: "--"; fontSize: 14; fontBold: true }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    Item { Layout.fillWidth: true }
                    MevaCoinComponents.StandardButton {
                        text: qsTr("Register") + translationManager.emptyString
                        primary: true
                        onClicked: registerNodeDialog.open()
                    }
                    MevaCoinComponents.StandardButton {
                        text: qsTr("Deregister") + translationManager.emptyString
                        onClicked: deregisterConfirmDialog.open()
                    }
                    MevaCoinComponents.StandardButton {
                        text: qsTr("Circles") + translationManager.emptyString
                        onClicked: circleManagerDialog.open()
                    }
                    MevaCoinComponents.StandardButton {
                        text: qsTr("Badge Progress") + translationManager.emptyString
                        onClicked: badgeProgressSheet.open()
                    }
                }
            }
            property real myNodeDashImplicit: myNodeDashLayout.implicitHeight + 30
        }

        Item { height: 15; width: 1 }

        // ── Network Overview ──────────────────────────────────────
        MevaCoinComponents.Label {
            text: qsTr("Network Overview") + translationManager.emptyString
            fontSize: 20; fontBold: true
        }

        Item { height: 5; width: 1 }

        Rectangle {
            Layout.fillWidth: true
            height: mobileMode ? 170 : 100
            color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
            radius: 8
            border.color: MevaCoinComponents.Style.dividerColor
            border.width: 1

            GridLayout {
                anchors.fill: parent; anchors.margins: 15
                columns: mobileMode ? 2 : 4; columnSpacing: 20; rowSpacing: 20

                ColumnLayout { Layout.alignment: Qt.AlignCenter
                    MevaCoinComponents.Label { text: qsTr("Active Nodes") + translationManager.emptyString; fontSize: mobileMode ? 10 : 11; opacity: 0.6 }
                    MevaCoinComponents.Label { id: activeNodesCount; text: "--"; fontSize: mobileMode ? 20 : 24; fontBold: true; color: MevaCoinComponents.Style.wookeyGreen }
                }
                ColumnLayout { Layout.alignment: Qt.AlignCenter
                    MevaCoinComponents.Label { text: qsTr("Pool Balance") + translationManager.emptyString; fontSize: mobileMode ? 10 : 11; opacity: 0.6 }
                    MevaCoinComponents.Label { id: poolBalanceLabel; text: "--"; fontSize: mobileMode ? 20 : 24; fontBold: true; color: MevaCoinComponents.Style.orange }
                }
                ColumnLayout { Layout.alignment: Qt.AlignCenter
                    MevaCoinComponents.Label { text: qsTr("Total Rewarded") + translationManager.emptyString; fontSize: mobileMode ? 10 : 11; opacity: 0.6 }
                    MevaCoinComponents.Label { id: totalRewardedLabel; text: "--"; fontSize: mobileMode ? 20 : 24; fontBold: true; color: MevaCoinComponents.Style.green }
                }
                ColumnLayout { Layout.alignment: Qt.AlignCenter
                    MevaCoinComponents.Label { text: qsTr("Avg Score") + translationManager.emptyString; fontSize: mobileMode ? 10 : 11; opacity: 0.6 }
                    MevaCoinComponents.Label { id: avgScoreLabel; text: "--"; fontSize: mobileMode ? 20 : 24; fontBold: true }
                }
            }
        }

        Item { height: 15; width: 1 }

        // ── Recent Badge Awards ───────────────────────────────────
        MevaCoinComponents.Label {
            text: qsTr("Recent Badge Awards") + translationManager.emptyString
            fontSize: 20; fontBold: true
        }
        Item { height: 5; width: 1 }

        Rectangle {
            Layout.fillWidth: true; Layout.minimumHeight: 60
            color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
            radius: 8; border.color: MevaCoinComponents.Style.dividerColor; border.width: 1
            visible: recentAwardsRepeater.count > 0

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 10
                Repeater {
                    id: recentAwardsRepeater
                    model: ListModel {}
                    delegate: RowLayout {
                        Layout.fillWidth: true; spacing: 8
                        Rectangle { width: 12; height: 12; radius: 6; color: badgeColor }
                        MevaCoinComponents.Label { text: badgeName; fontSize: 13; Layout.fillWidth: true }
                        MevaCoinComponents.Label { text: nodeId; fontSize: 11; opacity: 0.6; fontFamily: "Courier" }
                    }
                }
            }
        }

        MevaCoinComponents.Label {
            text: qsTr("No recent badge awards yet") + translationManager.emptyString
            fontSize: 13; opacity: 0.5
            visible: recentAwardsRepeater.count === 0
        }
    }

    // ── NODE LOOKUP DIALOG ────────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: lookupNodeDialog
        title: qsTr("Node Lookup") + translationManager.emptyString
        height: mobileMode ? 260 : 240
        width: Math.min(450, mevatrustPage.width * 0.92)

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 10
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
                Layout.fillWidth: true; spacing: 10
                Item { Layout.fillWidth: true }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Cancel") + translationManager.emptyString
                    onClicked: lookupNodeDialog.close()
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Set as My Node") + translationManager.emptyString
                    enabled: nodeIdInput.text.trim().length >= 64
                    onClicked: {
                        myNodeId = nodeIdInput.text.trim();
                        saveMyNode();
                        lookupNodeDialog.close();
                    }
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Search") + translationManager.emptyString
                    primary: true
                    enabled: nodeIdInput.text.trim().length >= 64
                    onClicked: {
                        lookupNodeDialog.close();
                        var nid = nodeIdInput.text.trim();
                        nodeDetailsSheet.nodeId = nid;
                        nodeDetailsSheet.open();
                        mevatrustManager.lookupNode(nid);
                        mevatrustManager.getNodeBadges(nid);
                        mevatrustManager.getNodeUptime(nid);
                        mevatrustManager.getNodeScore(nid);
                        mevatrustManager.getNodeRewards(nid);
                    }
                }
            }
        }
    }

    // ── NODE DETAILS DIALOG ──────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: nodeDetailsSheet
        title: qsTr("Node Details") + translationManager.emptyString
        property string nodeId: ""
        width: Math.min(650, mevatrustPage.width * 0.92)
        height: mobileMode ? 450 : 550

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 8

            MevaCoinComponents.Label { text: qsTr("Node ID:") + translationManager.emptyString; fontSize: 11; opacity: 0.6 }
            MevaCoinComponents.Label { id: detailNodeId; text: nodeDetailsSheet.nodeId; fontSize: 12; fontFamily: "Courier"; wrapMode: Text.Wrap }

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

            MevaCoinComponents.Label { text: qsTr("Badges Earned") + translationManager.emptyString; fontSize: 16; fontBold: true }

            Flow {
                Layout.fillWidth: true; spacing: 8
                Repeater {
                    id: badgeRepeater
                    model: ListModel {}
                    delegate: MevaCoinComponents.BadgeCard {
                        badgeName: model.badgeName; badgeDescription: model.badgeDescription
                        badgeColor: model.badgeColor; isEarned: model.isEarned; earnedHeight: model.earnedHeight
                    }
                }
            }
            MevaCoinComponents.Label { text: qsTr("No badges yet") + translationManager.emptyString; fontSize: 12; opacity: 0.5; visible: badgeRepeater.count === 0 }
        }
    }

    // ── MY NODE SHEET ────────────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: myNodeSheet
        title: qsTr("My Node Dashboard") + translationManager.emptyString
        width: Math.min(700, mevatrustPage.width * 0.94)
        height: mobileMode ? 500 : 600

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 8

            MevaCoinComponents.Label { text: qsTr("My Node ID") + translationManager.emptyString; fontSize: 11; opacity: 0.6 }
            RowLayout {
                Layout.fillWidth: true; spacing: 8
                MevaCoinComponents.LineEdit {
                    id: myNodeIdInput
                    Layout.fillWidth: true
                    text: myNodeId
                    placeholderText: qsTr("Enter 64 hex char node ID") + translationManager.emptyString
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Save") + translationManager.emptyString
                    primary: true
                    enabled: myNodeIdInput.text.trim().length >= 64
                    onClicked: {
                        myNodeId = myNodeIdInput.text.trim();
                        saveMyNode();
                    }
                }
            }

            Item { height: 5; width: 1 }

            GridLayout {
                columns: 2; columnSpacing: 20; rowSpacing: 6
                MevaCoinComponents.Label { text: qsTr("Status:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: myStatus; text: "--"; fontSize: 14; fontBold: true; color: MevaCoinComponents.Style.wookeyGreen }
                MevaCoinComponents.Label { text: qsTr("Score:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: myScore; text: "--"; fontSize: 14; fontBold: true }
                MevaCoinComponents.Label { text: qsTr("Uptime:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: myUptime; text: "--"; fontSize: 14; color: MevaCoinComponents.Style.orange }
                MevaCoinComponents.Label { text: qsTr("Uptime %:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: myUptimePct; text: "--"; fontSize: 14 }
                MevaCoinComponents.Label { text: qsTr("Rewards:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: myRewards; text: "--"; fontSize: 14; color: MevaCoinComponents.Style.green }
                MevaCoinComponents.Label { text: qsTr("Badges:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: myBadgeCount; text: "--"; fontSize: 14; fontBold: true }
                MevaCoinComponents.Label { text: qsTr("Penalties:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: myPenaltyCount; text: "--"; fontSize: 14 }
                MevaCoinComponents.Label { text: qsTr("Last Seen:") + translationManager.emptyString; fontSize: 12; opacity: 0.6 }
                MevaCoinComponents.Label { id: myLastSeen; text: "--"; fontSize: 12 }
            }

            Item { height: 8; width: 1 }

            RowLayout {
                Layout.fillWidth: true; spacing: 8
                Item { Layout.fillWidth: true }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Register Node") + translationManager.emptyString
                    primary: true
                    onClicked: { myNodeSheet.close(); registerNodeDialog.open(); }
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Deregister") + translationManager.emptyString
                    onClicked: { myNodeSheet.close(); deregisterConfirmDialog.open(); }
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Circles") + translationManager.emptyString
                    onClicked: { myNodeSheet.close(); circleManagerDialog.open(); }
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Refresh") + translationManager.emptyString
                    onClicked: refreshMyNode()
                }
            }

            Item { height: 8; width: 1 }

            MevaCoinComponents.Label { text: qsTr("Recent Incentive History") + translationManager.emptyString; fontSize: 16; fontBold: true }

            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
                radius: 6; border.color: MevaCoinComponents.Style.dividerColor; border.width: 1; clip: true

                Flickable {
                    anchors.fill: parent; anchors.margins: 8
                    contentHeight: myIncentiveList.implicitHeight; interactive: true
                    ColumnLayout {
                        id: myIncentiveList; width: parent.width
                        Repeater {
                            id: myIncentiveRepeater; model: ListModel {}
                            delegate: RowLayout {
                                Layout.fillWidth: true; spacing: 6; height: 24
                                MevaCoinComponents.Label { text: "#" + height; fontSize: 11; opacity: 0.6; width: 80 }
                                MevaCoinComponents.Label { text: type; fontSize: 11; Layout.fillWidth: true; color: typeColor }
                                MevaCoinComponents.Label { text: value; fontSize: 11; opacity: 0.7 }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── REGISTER NODE DIALOG ──────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: registerNodeDialog
        title: qsTr("Register Node On-Chain") + translationManager.emptyString
        width: Math.min(500, mevatrustPage.width * 0.92)
        height: mobileMode ? 380 : 400

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 10

            MevaCoinComponents.Label {
                text: qsTr("Register your node on the MevaTrust network.") + translationManager.emptyString
                fontSize: 13; wrapMode: Text.Wrap
            }

            MevaCoinComponents.Label {
                text: qsTr("Wallet Address:") + translationManager.emptyString
                fontSize: 11; opacity: 0.6
            }
            MevaCoinComponents.Label {
                id: regWalletAddr
                text: currentWallet ? currentWallet.address(0, 0) : "--"
                fontSize: 12; fontFamily: "Courier"
            }

            MevaCoinComponents.Label {
                text: qsTr("Node Public Key:") + translationManager.emptyString
                fontSize: 11; opacity: 0.6
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                MevaCoinComponents.LineEdit {
                    id: regNodePubkey
                    Layout.fillWidth: true
                    readOnly: true
                    placeholderText: qsTr("Click Detect to find your node key") + translationManager.emptyString
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Detect") + translationManager.emptyString
                    onClicked: {
                        if (!currentWallet) return;
                        var pk = currentWallet.readNodePubkey();
                        if (pk.length > 0) {
                            regNodePubkey.text = pk;
                            regNodeKeyStatus.text = qsTr("✓ Found") + translationManager.emptyString;
                            regNodeKeyStatus.color = MevaCoinComponents.Style.green;
                        } else {
                            regNodeKeyStatus.text = qsTr("Not found in ~/.mevacoin/mevatrust/") + translationManager.emptyString;
                            regNodeKeyStatus.color = "red";
                        }
                    }
                }
            }
            MevaCoinComponents.Label {
                id: regNodeKeyStatus
                fontSize: 10; opacity: 0.7
            }

            MevaCoinComponents.Label {
                text: qsTr("Port:") + translationManager.emptyString
                fontSize: 11; opacity: 0.6
            }
            MevaCoinComponents.LineEdit {
                id: regPort
                Layout.fillWidth: true
                placeholderText: qsTr("Optional: node port") + translationManager.emptyString
                validator: RegExpValidator { regExp: /[0-9]*/ }
            }

            Rectangle {
                Layout.fillWidth: true; height: 30; radius: 4
                color: Qt.rgba(1,0.8,0,0.1); border.color: Qt.rgba(1,0.8,0,0.3)
                MevaCoinComponents.Label {
                    anchors.fill: parent; anchors.margins: 6
                    text: qsTr("⚠ Creates a self-send tx (~0.001 MVC + fee). Ensure wallet has unlocked balance.") + translationManager.emptyString
                    fontSize: 10; wrapMode: Text.Wrap; color: MevaCoinComponents.Style.orange
                }
            }

            Item { height: 5; width: 1 }

            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Item { Layout.fillWidth: true }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Cancel") + translationManager.emptyString
                    onClicked: registerNodeDialog.close()
                }
                MevaCoinComponents.StandardButton {
                    id: registerBtn
                    text: qsTr("Register Node") + translationManager.emptyString
                    primary: true
                    enabled: regNodePubkey.text.trim().length > 0
                    onClicked: {
                        if (!currentWallet) return;
                        registerBtn.enabled = false;
                        registerNodeDialog.close();
                        var addr = currentWallet.address(0, 0);
                        var port = parseInt(regPort.text.trim()) || 0;
                        var extraHex = currentWallet.buildRegistrationExtra(addr, port);
                        if (extraHex.length === 0) {
                            mevatrustTxResultDialog.txSuccess = false;
                            mevatrustTxResultDialog.txError = qsTr("Failed to build registration - check node key file") + translationManager.emptyString;
                            mevatrustTxResultDialog.open();
                            registerBtn.enabled = true;
                            return;
                        }
                        var nodeId = currentWallet.lastNodeId;
                        myNodeId = nodeId;
                        appWindow.persistentSettings.mevatrust_node_id = nodeId;
                        currentWallet.saveNodeIdToFile(nodeId);
                        currentWallet.submitMevatrustTransactionAsync(extraHex);
                        // Re-enable after a timeout
                        registerNodeDialog.closeTimer.restart();
                    }
                }
            }
        }
        Timer {
            id: regBtnTimer
            interval: 3000; onTriggered: registerBtn.enabled = true
        }
    }

    // ── DEREGISTER CONFIRM ──────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: deregisterConfirmDialog
        title: qsTr("Deregister Node") + translationManager.emptyString
        width: Math.min(450, mevatrustPage.width * 0.92)
        height: 200

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 10

            MevaCoinComponents.Label {
                text: qsTr("Are you sure you want to deregister this node?") + translationManager.emptyString
                fontSize: 14; wrapMode: Text.Wrap
            }
            MevaCoinComponents.Label {
                text: qsTr("Node ID: ") + myNodeId.substring(0, 32) + "..." + translationManager.emptyString
                fontSize: 12; fontFamily: "Courier"; opacity: 0.6
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Item { Layout.fillWidth: true }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Cancel") + translationManager.emptyString
                    onClicked: deregisterConfirmDialog.close()
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Confirm Deregister") + translationManager.emptyString
                    primary: true
                    onClicked: {
                        deregisterConfirmDialog.close();
                        mevatrustManager.unregisterNode(
                            myNodeId,
                            currentWallet ? currentWallet.address(0, 0) : "",
                            ""
                        );
                    }
                }
            }
        }
    }

    // ── BADGE PROGRESS SHEET ──────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: badgeProgressSheet
        title: qsTr("Badge Progress") + translationManager.emptyString
        width: Math.min(600, mevatrustPage.width * 0.92)
        height: mobileMode ? 400 : 500

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 8

            MevaCoinComponents.Label {
                text: qsTr("Detailed badge requirements and progress for your node") + translationManager.emptyString
                fontSize: 12; opacity: 0.7
            }
            Item { height: 5; width: 1 }

            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
                radius: 6; border.color: MevaCoinComponents.Style.dividerColor; border.width: 1; clip: true

                Flickable {
                    anchors.fill: parent; anchors.margins: 8
                    contentHeight: badgeProgressList.implicitHeight; interactive: true
                    ColumnLayout {
                        id: badgeProgressList; width: parent.width; spacing: 6
                        Repeater {
                            id: badgeProgressRepeater; model: ListModel {}
                            delegate: Rectangle {
                                Layout.fillWidth: true; height: 70; radius: 6
                                color: Qt.rgba(1,1,1,0.03)
                                border.color: Qt.rgba(1,1,1,0.08); border.width: 1

                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 10; spacing: 12

                                    Rectangle { width: 24; height: 24; radius: 12; color: badgeColor; opacity: isEarned ? 1 : 0.4 }

                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 2
                                        MevaCoinComponents.Label {
                                            text: badgeName
                                            fontSize: 13; fontBold: true; opacity: isEarned ? 1 : 0.6
                                        }
                                        MevaCoinComponents.Label {
                                            text: isEarned ? (qsTr("✅ Earned at block ") + earnedHeight) : (progressText || qsTr("Not yet earned")) + translationManager.emptyString
                                            fontSize: 10; opacity: 0.5
                                        }
                                    }

                                    MevaCoinComponents.Label {
                                        text: isEarned ? "100%" : progressPct + "%"
                                        fontSize: 16; fontBold: true
                                        color: isEarned ? MevaCoinComponents.Style.green : MevaCoinComponents.Style.defaultFontColor
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── CIRCLE MANAGER DIALOG ─────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: circleManagerDialog
        title: qsTr("Circle Manager") + translationManager.emptyString
        width: Math.min(650, mevatrustPage.width * 0.92)
        height: mobileMode ? 450 : 500

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 8

            RowLayout {
                Layout.fillWidth: true
                MevaCoinComponents.Label { text: qsTr("Your Circles") + translationManager.emptyString; fontSize: 18; fontBold: true }
                Item { Layout.fillWidth: true }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Create Circle") + translationManager.emptyString
                    primary: true
                    onClicked: createCircleDialog.open()
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Refresh") + translationManager.emptyString
                    onClicked: {
                        var pk = currentWallet ? currentWallet.publicSpendKey : "";
                        mevatrustManager.circleList(pk);
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
                radius: 6; border.color: MevaCoinComponents.Style.dividerColor; border.width: 1; clip: true

                Flickable {
                    anchors.fill: parent; anchors.margins: 8
                    contentHeight: circleListLayout.implicitHeight; interactive: true
                    ColumnLayout {
                        id: circleListLayout; width: parent.width; spacing: 4
                        Repeater {
                            id: circleRepeater; model: ListModel {}
                            delegate: Rectangle {
                                Layout.fillWidth: true; height: 44; radius: 4
                                color: index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.03)

                                RowLayout {
                                    anchors.fill: parent; anchors.margins: { left: 8; right: 8 }; spacing: 8
                                    MevaCoinComponents.Label {
                                        text: circleName; fontSize: 13; fontBold: true; Layout.fillWidth: true
                                    }
                                    MevaCoinComponents.Label {
                                        text: qsTr("Members: ") + memberCount; fontSize: 11; opacity: 0.6
                                    }
                                    MevaCoinComponents.Label {
                                        text: isAdmin ? qsTr("Admin") : qsTr("Member"); fontSize: 11
                                        color: isAdmin ? MevaCoinComponents.Style.wookeyGreen : MevaCoinComponents.Style.defaultFontColor
                                    }
                                    MevaCoinComponents.StandardButton {
                                        text: qsTr("Info") + translationManager.emptyString; small: true
                                        onClicked: {
                                            mevatrustManager.circleInfo(circleId);
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
            onCircleListReceived: {
                circleRepeater.model.clear();
                var circles = result.circles || result.Circles || [];
                for (var i = 0; i < circles.length; i++) {
                    var c = circles[i];
                    circleRepeater.model.append({
                        circleId: c.circle_id || c.circleId || "",
                        circleName: c.name || "Unnamed",
                        memberCount: c.member_count || c.memberCount || 0,
                        isAdmin: (c.admin_pubkey || c.adminPubkey || "") === (currentWallet ? currentWallet.publicSpendKey : "")
                    });
                }
            }
            onCircleInfoReceived: {
                circleInfoDialog.circleData = result;
                circleInfoDialog.open();
            }
        }
    }

    // ── CREATE CIRCLE DIALOG ──────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: createCircleDialog
        title: qsTr("Create New Circle") + translationManager.emptyString
        width: Math.min(450, mevatrustPage.width * 0.92)
        height: 250

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 10

            MevaCoinComponents.Label { text: qsTr("Circle Name:") + translationManager.emptyString; fontSize: 13 }
            MevaCoinComponents.LineEdit {
                id: circleNameInput
                Layout.fillWidth: true
                placeholderText: qsTr("Enter circle name") + translationManager.emptyString
            }

            MevaCoinComponents.Label { text: qsTr("Admin Public Key:") + translationManager.emptyString; fontSize: 11; opacity: 0.6 }
            MevaCoinComponents.Label {
                id: circleAdminKey
                text: currentWallet ? currentWallet.publicSpendKey : "--"
                fontSize: 11; fontFamily: "Courier"; wrapMode: Text.Wrap
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Item { Layout.fillWidth: true }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Cancel") + translationManager.emptyString
                    onClicked: createCircleDialog.close()
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Create") + translationManager.emptyString
                    primary: true
                    enabled: circleNameInput.text.trim().length > 0
                    onClicked: {
                        createCircleDialog.close();
                        mevatrustManager.circleCreate(
                            circleNameInput.text.trim(),
                            currentWallet ? currentWallet.publicSpendKey : ""
                        );
                    }
                }
            }
        }
    }

    // ── CIRCLE INFO DIALOG ────────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: circleInfoDialog
        title: qsTr("Circle Info") + translationManager.emptyString
        property var circleData: ({})
        width: Math.min(500, mevatrustPage.width * 0.92)
        height: 350

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 8

            MevaCoinComponents.Label { text: qsTr("Name:") + translationManager.emptyString; fontSize: 11; opacity: 0.6 }
            MevaCoinComponents.Label { id: ciName; text: circleInfoDialog.circleData.name || "--"; fontSize: 16; fontBold: true }

            GridLayout {
                columns: 2; columnSpacing: 20; rowSpacing: 4
                MevaCoinComponents.Label { text: qsTr("Circle ID:") + translationManager.emptyString; fontSize: 11; opacity: 0.6 }
                MevaCoinComponents.Label { id: ciId; text: (circleInfoDialog.circleData.circle_id || circleInfoDialog.circleData.circleId || "").substring(0, 24) + "..."; fontSize: 11; fontFamily: "Courier" }

                MevaCoinComponents.Label { text: qsTr("Admin:") + translationManager.emptyString; fontSize: 11; opacity: 0.6 }
                MevaCoinComponents.Label { id: ciAdmin; text: (circleInfoDialog.circleData.admin_pubkey || circleInfoDialog.circleData.adminPubkey || "").substring(0, 16) + "..."; fontSize: 11; fontFamily: "Courier" }

                MevaCoinComponents.Label { text: qsTr("Members:") + translationManager.emptyString; fontSize: 11; opacity: 0.6 }
                MevaCoinComponents.Label { id: ciMembers; text: {
                    var m = circleInfoDialog.circleData.members || circleInfoDialog.circleData.Members || [];
                    return m.length ? m.length.toString() : "0";
                }; fontSize: 14; fontBold: true }

                MevaCoinComponents.Label { text: qsTr("Created:") + translationManager.emptyString; fontSize: 11; opacity: 0.6 }
                MevaCoinComponents.Label { id: ciCreated; text: circleInfoDialog.circleData.created_height ? qsTr("Block ") + circleInfoDialog.circleData.created_height : "--"; fontSize: 12 }
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 8
                Item { Layout.fillWidth: true }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Join") + translationManager.emptyString
                    onClicked: {
                        var pk = currentWallet ? currentWallet.publicSpendKey : "";
                        mevatrustManager.circleJoin(circleInfoDialog.circleData.circle_id || "", pk, pk);
                    }
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Leave") + translationManager.emptyString
                    onClicked: {
                        var pk = currentWallet ? currentWallet.publicSpendKey : "";
                        mevatrustManager.circleLeave(circleInfoDialog.circleData.circle_id || "", pk, pk);
                    }
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Disband") + translationManager.emptyString
                    onClicked: {
                        var pk = currentWallet ? currentWallet.publicSpendKey : "";
                        mevatrustManager.circleDisband(circleInfoDialog.circleData.circle_id || "", pk);
                    }
                }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Close") + translationManager.emptyString
                    onClicked: circleInfoDialog.close()
                }
            }
        }
    }

    // ── NETWORK STATS DIALOG ──────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: networkStatsSheet
        title: qsTr("Network Statistics") + translationManager.emptyString
        width: Math.min(500, mevatrustPage.width * 0.92)
        height: mobileMode ? 350 : 400

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
            MevaCoinComponents.Label { text: qsTr("Top Nodes") + translationManager.emptyString; fontSize: 16; fontBold: true }
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
                radius: 6; border.color: MevaCoinComponents.Style.dividerColor; border.width: 1; clip: true
                Flickable {
                    anchors.fill: parent; anchors.margins: 8
                    contentHeight: topNodeList.implicitHeight; interactive: true
                    ColumnLayout {
                        id: topNodeList; width: parent.width
                        Repeater {
                            id: topNodesRepeater; model: ListModel {}
                            delegate: RowLayout {
                                Layout.fillWidth: true; spacing: 6
                                MevaCoinComponents.Label { text: (index + 1) + "."; fontSize: 12; opacity: 0.6 }
                                MevaCoinComponents.Label { text: nodeIdShort; fontSize: 11; fontFamily: "Courier" }
                                Item { Layout.fillWidth: true }
                                MevaCoinComponents.Label { text: score; fontSize: 12; fontBold: true; color: MevaCoinComponents.Style.wookeyGreen }
                                MevaCoinComponents.Label { text: badges; fontSize: 11; opacity: 0.6 }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── BADGE GALLERY DIALOG ──────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: badgeGallerySheet
        title: qsTr("Badge Gallery") + translationManager.emptyString
        width: Math.min(600, mevatrustPage.width * 0.92)
        height: mobileMode ? 400 : 500

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
                radius: 6; border.color: MevaCoinComponents.Style.dividerColor; border.width: 1; clip: true
                Flickable {
                    anchors.fill: parent; anchors.margins: 8
                    contentHeight: badgesGalleryList.implicitHeight; interactive: true
                    Flow {
                        id: badgesGalleryList; width: parent.width; spacing: 10
                        Repeater {
                            id: badgeGalleryRepeater; model: ListModel {}
                            delegate: MevaCoinComponents.BadgeCard {
                                badgeName: model.badgeName; badgeDescription: model.badgeDescription
                                badgeColor: model.badgeColor; isEarned: false
                                badgeProgress: model.hasProgress ? model.progressText : ""
                            }
                        }
                    }
                }
            }
        }
    }

    // ── TOP NODES DIALOG ──────────────────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: topNodesSheet
        title: qsTr("Top Nodes") + translationManager.emptyString
        width: Math.min(600, mevatrustPage.width * 0.92)
        height: mobileMode ? 400 : 480

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 8
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
                radius: 6; border.color: MevaCoinComponents.Style.dividerColor; border.width: 1; clip: true
                Flickable {
                    anchors.fill: parent; anchors.margins: 8
                    contentHeight: topNodesFullList.implicitHeight; interactive: true
                    ColumnLayout {
                        id: topNodesFullList; width: parent.width
                        Repeater {
                            id: topNodesFullRepeater; model: ListModel {}
                            delegate: Rectangle {
                                Layout.fillWidth: true; height: 44
                                color: index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.03); radius: 4
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: { left: 8; right: 8 }; spacing: 8
                                    MevaCoinComponents.Label {
                                        text: ("#" + (index + 1)); fontSize: 14; fontBold: true; width: 30
                                        color: index < 3 ? MevaCoinComponents.Style.wookeyGreen : MevaCoinComponents.Style.defaultFontColor
                                    }
                                    ColumnLayout { spacing: 1
                                        MevaCoinComponents.Label { text: nodeIdShort; fontSize: 12; fontFamily: "Courier"; fontBold: true }
                                        MevaCoinComponents.Label { text: walletShort; fontSize: 10; opacity: 0.5; fontFamily: "Courier" }
                                    }
                                    Item { Layout.fillWidth: true }
                                    MevaCoinComponents.Label { text: qsTr("Score:") + translationManager.emptyString; fontSize: 10; opacity: 0.5 }
                                    MevaCoinComponents.Label { text: score; fontSize: 14; fontBold: true; color: MevaCoinComponents.Style.wookeyGreen }
                                    MevaCoinComponents.Label { text: qsTr("Badges:") + translationManager.emptyString; fontSize: 10; opacity: 0.5 }
                                    MevaCoinComponents.Label { text: badgeCount; fontSize: 14; fontBold: true; color: parseFloat(badgeCount) > 3 ? MevaCoinComponents.Style.wookeyGreen : parseFloat(badgeCount) > 1 ? MevaCoinComponents.Style.orange : MevaCoinComponents.Style.defaultFontColor }
                                    MevaCoinComponents.Label { text: qsTr("Rewards:") + translationManager.emptyString; fontSize: 10; opacity: 0.5 }
                                    MevaCoinComponents.Label { text: totalRewards; fontSize: 12 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── TRANSACTION RESULT FEEDBACK ──────────────────────────────
    MevaCoinComponents.StandardDialog {
        id: mevatrustTxResultDialog
        property bool txSuccess: false
        property string txId: ""
        property string txError: ""
        title: txSuccess ? qsTr("Transaction Successful") + translationManager.emptyString : qsTr("Transaction Failed") + translationManager.emptyString
        width: Math.min(500, mevatrustPage.width * 0.92)
        height: 200

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 10
            MevaCoinComponents.Label {
                text: mevatrustTxResultDialog.txSuccess ? qsTr("✅ Transaction sent successfully!") + translationManager.emptyString : qsTr("❌ ") + mevatrustTxResultDialog.txError + translationManager.emptyString
                fontSize: 14; wrapMode: Text.Wrap
            }
            MevaCoinComponents.Label {
                visible: mevatrustTxResultDialog.txSuccess && mevatrustTxResultDialog.txId.length > 0
                text: qsTr("TXID: ") + mevatrustTxResultDialog.txId + translationManager.emptyString
                fontSize: 11; fontFamily: "Courier"; wrapMode: Text.Wrap
            }
            MevaCoinComponents.Label {
                visible: mevatrustTxResultDialog.txSuccess
                text: qsTr("Wait 1-2 blocks (~2 min) for confirmation.") + translationManager.emptyString
                fontSize: 11; opacity: 0.6
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                MevaCoinComponents.StandardButton {
                    text: qsTr("Close") + translationManager.emptyString
                    onClicked: mevatrustTxResultDialog.close()
                }
            }
        }
    }

    // ── Connections ──────────────────────────────────────────────
    Connections {
        target: mevatrustManager

        // Network stats
        onNetworkStatsReceived: {
            var data = stats;
            activeNodesCount.text = (data.active_nodes || data.active_nodes === 0) ? data.active_nodes : "--";
            poolBalanceLabel.text = stats.pool_balance ? walletManager.displayAmount(stats.pool_balance) : "--";
            totalRewardedLabel.text = stats.total_distributed ? walletManager.displayAmount(stats.total_distributed) : "--";
            avgScoreLabel.text = stats.average_score ? parseFloat(stats.average_score).toFixed(2) : "--";
            nsActiveNodes.text = (stats.active_nodes || stats.active_nodes === 0) ? stats.active_nodes : "--";
            nsEligibleNodes.text = (stats.total_eligible_nodes || stats.total_eligible_nodes === 0) ? stats.total_eligible_nodes : "--";
            nsPoolBalance.text = stats.pool_balance ? walletManager.displayAmount(stats.pool_balance) : "--";
            nsTotalDistributed.text = stats.total_distributed ? walletManager.displayAmount(stats.total_distributed) : "--";
            nsAvgUptime.text = stats.average_uptime ? parseFloat(stats.average_uptime).toFixed(1) + "%" : "--";
            nsAvgScore.text = stats.average_score ? parseFloat(stats.average_score).toFixed(4) : "--";
            nsLastDist.text = stats.last_distribution_height ? qsTr("Block ") + stats.last_distribution_height : "--";
        }

        // Top nodes
        onTopNodesReceived: {
            var data = nodes;
            topNodesRepeater.model.clear();
            topNodesFullRepeater.model.clear();
            recentAwardsRepeater.model.clear();
            var nodeList = data.nodes || [];
            for (var i = 0; i < nodeList.length; i++) {
                var n = nodeList[i];
                var shortId = n.node_id ? n.node_id.toString().substring(0, 12) + "..." : "--";
                var shortWallet = n.wallet_address ? n.wallet_address.toString().substring(0, 12) + "..." : "";
                var scoreStr = n.score ? parseFloat(n.score).toFixed(2) : "0";
                var badgeStr = n.badge_count ? String(n.badge_count) + " badges" : "0 badges";
                var badgesCount = n.badge_count || 0;
                var rewardsStr = n.total_rewards ? walletManager.displayAmount(n.total_rewards) : "0";

                topNodesRepeater.model.append({ nodeIdShort: shortId, score: scoreStr, badges: badgeStr });
                topNodesFullRepeater.model.append({
                    nodeIdShort: shortId, walletShort: shortWallet,
                    score: scoreStr, badgeCount: String(badgesCount), totalRewards: rewardsStr
                });

                if (i < 5) {
                    recentAwardsRepeater.model.append({
                        badgeName: n.badge_types && n.badge_types.length > 0 ? n.badge_types[0] : "Active",
                        nodeId: shortId,
                        badgeColor: badgeCount > 3 ? MevaCoinComponents.Style.wookeyGreen :
                                    badgeCount > 1 ? MevaCoinComponents.Style.orange : MevaCoinComponents.Style.green
                    });
                }
            }
        }

        // Badge requirements
        onBadgeRequirementsReceived: {
            badgeGalleryRepeater.model.clear();
            var badges = badges.badges || [];
            for (var i = 0; i < badges.length; i++) {
                var b = badges[i];
                badgeGalleryRepeater.model.append({
                    badgeName: b.name || b.type_name || "Badge",
                    badgeDescription: b.description || b.details || "",
                    badgeColor: badgeColorFor(b.name || b.type_name || ""),
                    hasProgress: false, progressText: ""
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
                    badgeGalleryRepeater.model.append({ badgeName: ab.name, badgeDescription: ab.desc, badgeColor: ab.color, hasProgress: false, progressText: "" });
                }
            }
        }

        // Node status (for details dialog)
        onNodeStatusReceived: {
            detailStatus.text = status.is_active ? (status.is_synced ? qsTr("Active & Synced") : qsTr("Active")) : qsTr("Inactive");
            detailLastSeen.text = status.last_seen ? new Date(status.last_seen * 1000).toLocaleString() : "--";

            if (status.node_id === myNodeId) {
                myStatus.text = status.is_active ? (status.is_synced ? qsTr("Active & Synced") : qsTr("Active")) : qsTr("Inactive");
                myLastSeen.text = status.last_seen ? new Date(status.last_seen * 1000).toLocaleString() : "--";
                dashStatus.text = status.is_active ? (status.is_synced ? qsTr("✅ Synced") : qsTr("Active")) : qsTr("Inactive");
            }
        }

        onNodeScoreReceived: {
            detailScore.text = score.score ? parseFloat(score.score).toFixed(4) : "--";
            if (score.node_id === myNodeId) {
                myScore.text = score.score ? parseFloat(score.score).toFixed(4) : "--";
                dashScore.text = score.score ? parseFloat(score.score).toFixed(2) : "--";
            }
        }

        onNodeUptimeReceived: {
            var hours = uptime.uptime_seconds ? (uptime.uptime_seconds / 3600).toFixed(1) : "0";
            var pct = uptime.uptime_percentage ? parseFloat(uptime.uptime_percentage).toFixed(1) + "%" : "--";
            detailUptime.text = hours + " " + qsTr("hours");
            detailUptimePct.text = pct;
            if (uptime.node_id === myNodeId) {
                myUptime.text = hours + " " + qsTr("hours");
                myUptimePct.text = pct;
                dashUptime.text = hours + "h";
                dashUptimePct.text = pct;
            }
        }

        onNodeBadgesReceived: {
            badgeRepeater.model.clear();
            var badges = badges.badges || [];
            var count = 0;
            for (var i = 0; i < badges.length; i++) {
                var b = badges[i];
                var earned = b.earned !== false;
                if (earned) count++;
                badgeRepeater.model.append({
                    badgeName: b.name || b.type_name || "Badge",
                    badgeDescription: b.description || "",
                    badgeColor: badgeColorFor(b.type_name || b.name || ""),
                    isEarned: earned,
                    earnedHeight: b.awarded_height || 0
                });
            }
            myBadgeCount.text = count + "/" + badges.length;
            dashBadges.text = String(count);
        }

        onNodeRewardsReceived: {
            var rewardStr = rewards.total_rewards ? walletManager.displayAmount(rewards.total_rewards) : "0";
            detailRewards.text = rewardStr;
            myRewards.text = rewardStr;
            dashRewards.text = rewardStr;
        }

        onRewardHistoryReceived: {
            myIncentiveRepeater.model.clear();
            var entries = history.entries || history.records || [];
            for (var i = 0; i < entries.length; i++) {
                var e = entries[i];
                var isBadge = e.badge_type && e.badge_type.length > 0;
                myIncentiveRepeater.model.append({
                    height: e.height || 0,
                    type: isBadge ? ("🏅 " + e.badge_type) : (qsTr("Reward") + translationManager.emptyString),
                    value: isBadge ? "" : (e.amount ? walletManager.displayAmount(e.amount) : ""),
                    typeColor: isBadge ? badgeColorFor(e.badge_type) : MevaCoinComponents.Style.green
                });
            }
        }

        // Write RPC response handlers
        onRegisterNodeReceived: {
            var msg = result.status || result.message || "";
            var nodeId = result.node_id || "";
            mevatrustTxResultDialog.txSuccess = result.success === true || result.success === "true";
            mevatrustTxResultDialog.txId = nodeId;
            mevatrustTxResultDialog.txError = msg;
            mevatrustTxResultDialog.open();
            if (mevatrustTxResultDialog.txSuccess) refreshMyNode();
        }

        onUnregisterNodeReceived: {
            mevatrustTxResultDialog.txSuccess = result.success === true || result.success === "true";
            mevatrustTxResultDialog.txId = "";
            mevatrustTxResultDialog.txError = result.status || result.message || "";
            mevatrustTxResultDialog.open();
            if (mevatrustTxResultDialog.txSuccess) {
                myNodeId = "";
                appWindow.persistentSettings.mevatrust_node_id = "";
            }
        }

        onCircleCreateReceived: {
            mevatrustTxResultDialog.txSuccess = result.success === true || result.success === "true";
            mevatrustTxResultDialog.txId = result.circle_id || "";
            mevatrustTxResultDialog.txError = result.status || "";
            mevatrustTxResultDialog.open();
            if (mevatrustTxResultDialog.txSuccess) {
                var pk = currentWallet ? currentWallet.publicSpendKey : "";
                mevatrustManager.circleList(pk);
            }
        }

        onCircleJoinReceived: {
            mevatrustTxResultDialog.txSuccess = result.success === true || result.success === "true";
            mevatrustTxResultDialog.txId = "";
            mevatrustTxResultDialog.txError = result.status || "";
            mevatrustTxResultDialog.open();
            if (mevatrustTxResultDialog.txSuccess) {
                var pk = currentWallet ? currentWallet.publicSpendKey : "";
                mevatrustManager.circleList(pk);
            }
        }

        onCircleLeaveReceived: {
            mevatrustTxResultDialog.txSuccess = result.success === true || result.success === "true";
            mevatrustTxResultDialog.txId = "";
            mevatrustTxResultDialog.txError = result.status || "";
            mevatrustTxResultDialog.open();
            if (mevatrustTxResultDialog.txSuccess) {
                var pk = currentWallet ? currentWallet.publicSpendKey : "";
                mevatrustManager.circleList(pk);
            }
        }

        onCircleChangeAdminReceived: {
            mevatrustTxResultDialog.txSuccess = result.success === true || result.success === "true";
            mevatrustTxResultDialog.txError = result.status || "";
            mevatrustTxResultDialog.open();
        }

        onCircleDisbandReceived: {
            mevatrustTxResultDialog.txSuccess = result.success === true || result.success === "true";
            mevatrustTxResultDialog.txError = result.status || "";
            mevatrustTxResultDialog.open();
            var pk = currentWallet ? currentWallet.publicSpendKey : "";
            mevatrustManager.circleList(pk);
        }

        onPenaltyHistoryReceived: {
            var entries = result.entries || [];
            myPenaltyCount.text = String(entries.length);
            dashPenalties.text = entries.length > 0 ? String(entries.length) : "0";
        }

        onEligibleNodesReceived: {}
        onBanNodeReceived: {}
        onUnbanNodeReceived: {}

        // Wallet tx result
        onErrorOccurred: {
            console.log("Mevatrust error:", error);
        }
    }

    Connections {
        target: currentWallet
        onMevatrustTransactionCompleted: {
            mevatrustTxResultDialog.txSuccess = success;
            mevatrustTxResultDialog.txId = txid;
            mevatrustTxResultDialog.txError = error;
            mevatrustTxResultDialog.open();
            if (success) refreshMyNode();
        }
    }

    // ── Badge color helper ────────────────────────────────────────
    function badgeColorFor(name) {
        var colors = {
            "Active Miner": "#4CAF50", "Full Node Operator": "#2196F3",
            "Stable Node": "#9C27B0", "Core Network Node": "#FF9800",
            "Long Uptime Node": "#F44336", "Early Supporter": "#E91E63",
            "Network Validator": "#00BCD4", "Bridge Node": "#795548",
            "Privacy Guardian": "#607D8B", "Relay Master": "#CDDC39",
            "Welcome": "#FF5722"
        };
        return colors[name] || MevaCoinComponents.Style.wookeyGreen;
    }
}
