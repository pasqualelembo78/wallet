// Copyright (c) 2014-2025, The MevaCoin Project
// All rights reserved. BSD License — see LICENSE for details.

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

import "../components" as MevaCoinComponents

Rectangle {
    id: miningPage
    color: "transparent"

    property int miningHeight: miningCol.implicitHeight + 80

    property bool miningActive: false
    property double hashRate: 0.0
    property bool isLocalNode: typeof appWindow !== "undefined" && appWindow.currentDaemonAddress
                               ? walletManager.isDaemonLocal(appWindow.currentDaemonAddress) : false

    function refresh() {
        if (typeof appWindow !== "undefined" && appWindow.currentWallet) {
            var hr = walletManager.miningHashRate();
            var mining = walletManager.isMining();
            miningActive = mining;
            hashRate = hr;
            walletManager.miningStatusAsync();
        }
        isLocalNode = typeof appWindow !== "undefined" && appWindow.currentDaemonAddress
                      ? walletManager.isDaemonLocal(appWindow.currentDaemonAddress) : false
    }

    Connections {
        target: walletManager
        onMiningStatus: {
            miningActive = isMining;
            if (!isMining) hashRate = 0.0;
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: miningCol.implicitHeight + 80
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar { }

        ColumnLayout {
            id: miningCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            anchors.topMargin: 24
            spacing: 16

            Text {
                Layout.fillWidth: true
                text: qsTr("Mining") + translationManager.emptyString
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 22
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }

            Rectangle {
                Layout.fillWidth: true
                color: "#1AFFA500"
                radius: 8
                border.color: "#33FFA500"
                border.width: 1
                padding: 12

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("⚠ Server-Side Mining Only") + translationManager.emptyString
                        font.pixelSize: 14
                        font.bold: true
                        color: "#CC8800"
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Mining is performed exclusively on the remote trusted node (server). "
                                + "Your mobile device never executes mining calculations. "
                                + "This feature sends RPC commands to the connected daemon, "
                                + "which runs the mining process on the server hardware. "
                                + "No mining threads run on this device, ensuring no battery drain, "
                                + "overheating, or hardware wear.") + translationManager.emptyString
                        font.pixelSize: 12
                        color: "#885500"
                        wrapMode: Text.WordWrap
                    }
                }
            }

            MevaCoinComponents.Label {
                text: qsTr("Connected node") + translationManager.emptyString
                fontSize: 14
            }

            Text {
                Layout.fillWidth: true
                text: appWindow.currentDaemonAddress || "--"
                font.family: MevaCoinComponents.Style.fontMono.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }

            Text {
                Layout.fillWidth: true
                visible: isLocalNode
                text: qsTr("⚠ Local node detected. Mining is only available when connected to a remote server.") + translationManager.emptyString
                font.pixelSize: 12
                color: "#FF6B6B"
                wrapMode: Text.WordWrap
            }

            MevaCoinComponents.Label {
                text: qsTr("Mining address") + translationManager.emptyString
                fontSize: 14
            }

            Text {
                Layout.fillWidth: true
                text: (typeof appWindow !== "undefined" && appWindow.currentWallet)
                      ? appWindow.currentWallet.address(0, 0) : "--"
                font.family: MevaCoinComponents.Style.fontMono.name
                font.pixelSize: 11
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
                elide: Text.ElideMiddle
                maximumLineCount: 2
            }

            MevaCoinComponents.Label {
                text: qsTr("Threads") + translationManager.emptyString
                fontSize: 14
            }

            SpinBox {
                id: threadCount
                from: 1
                to: 16
                value: 1
                editable: true
                enabled: !miningActive
                Layout.preferredWidth: 120
            }

            RowLayout {
                spacing: 12

                MevaCoinComponents.StandardButton {
                    id: startBtn
                    text: miningActive ? qsTr("Stop Mining") : qsTr("Start Mining")
                    small: appWindow.mobileMode
                    enabled: typeof appWindow !== "undefined" && appWindow.currentWallet
                             && appWindow.currentWallet.connectionStatus === Wallet.ConnectionStatus_Connected
                             && !isLocalNode
                    onClicked: {
                        if (miningActive) {
                            var stopped = walletManager.stopMining();
                            if (stopped) {
                                miningActive = false;
                                hashRate = 0.0;
                                appWindow.showStatusMessage(qsTr("Mining stopped"), 3);
                            } else {
                                appWindow.showStatusMessage(qsTr("Failed to stop mining"), 3);
                            }
                        } else {
                            var addr = appWindow.currentWallet.address(0, 0);
                            var started = walletManager.startMining(addr, threadCount.value, false, true);
                            if (started) {
                                miningActive = true;
                                appWindow.showStatusMessage(qsTr("Mining started on ") + appWindow.currentDaemonAddress, 3);
                            } else {
                                appWindow.showStatusMessage(qsTr("Failed to start mining — daemon must be unrestricted"), 5);
                            }
                        }
                    }
                }

                MevaCoinComponents.StandardButton {
                    text: qsTr("Refresh")
                    small: appWindow.mobileMode
                    onClicked: refresh()
                }
            }

            MevaCoinComponents.Label {
                text: qsTr("Status") + translationManager.emptyString
                fontSize: 14
            }

            GridLayout {
                columns: 2
                columnSpacing: 16
                rowSpacing: 8
                Layout.fillWidth: true

                Text {
                    text: qsTr("Active:") + translationManager.emptyString
                    font.pixelSize: 13
                    color: MevaCoinComponents.Style.defaultFontColor
                }
                Text {
                    text: miningActive ? qsTr("Yes") : qsTr("No")
                    font.pixelSize: 13
                    color: miningActive ? "#00CC66" : "#FF6B6B"
                    font.bold: true
                }

                Text {
                    text: qsTr("Hash Rate:") + translationManager.emptyString
                    font.pixelSize: 13
                    color: MevaCoinComponents.Style.defaultFontColor
                }
                Text {
                    text: miningActive ? hashRate.toFixed(1) + qsTr(" H/s") : "--"
                    font.pixelSize: 13
                    color: MevaCoinComponents.Style.defaultFontColor
                    font.family: MevaCoinComponents.Style.fontMono.name
                }

                Text {
                    text: qsTr("Daemon:") + translationManager.emptyString
                    font.pixelSize: 13
                    color: MevaCoinComponents.Style.defaultFontColor
                }
                Text {
                    text: appWindow.currentDaemonAddress || "--"
                    font.pixelSize: 13
                    color: MevaCoinComponents.Style.defaultFontColor
                    font.family: MevaCoinComponents.Style.fontMono.name
                    elide: Text.ElideMiddle
                }
            }

            Text {
                Layout.fillWidth: true
                visible: typeof appWindow !== "undefined" && appWindow.currentWallet
                         && appWindow.currentWallet.connectionStatus !== Wallet.ConnectionStatus_Connected
                text: qsTr("Connect to an unrestricted remote node to enable mining controls.") + translationManager.emptyString
                font.pixelSize: 11
                color: "#FFA500"
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                visible: typeof appWindow !== "undefined" && appWindow.currentWallet
                         && appWindow.currentWallet.connectionStatus === Wallet.ConnectionStatus_Connected
                         && !isLocalNode
                text: qsTr("The remote daemon must be started with --restricted-rpc disabled. "
                         + "Mining commands are sent to the connected server via RPC. "
                         + "All mining computation is performed on the server hardware, not on this device.") + translationManager.emptyString
                font.pixelSize: 11
                color: MevaCoinComponents.Style.blackTheme ? "#AAAAAA" : "#777777"
                wrapMode: Text.WordWrap
            }
        }
    }
}
