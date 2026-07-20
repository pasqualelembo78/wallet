// Copyright (c) 2014-2024, The MevaCoin Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
// DAMAGE.

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import FontAwesome 1.0

import "../../components" as MevaCoinComponents
import "../../components/effects" as MevaCoinEffects

Rectangle{
    color: "transparent"
    Layout.fillWidth: true
    property alias nodeHeight: root.height

    /* main layout */
    ColumnLayout {
        id: root
        anchors.margins: 20
        anchors.topMargin: 0

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 0

        // ── BANNER STATO NODO ────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 10
            implicitHeight: daemonStatusCol.implicitHeight + 20
            radius: 8
            color: appWindow.daemonSynced    ? "#1a3025"
                   : appWindow.daemonRunning ? "#2d2308" : "#3d1f1f"
            border.color: appWindow.daemonSynced    ? "#3fb950"
                          : appWindow.daemonRunning ? "#f0c040" : "#f85149"
            border.width: 1

            ColumnLayout {
                id: daemonStatusCol
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                spacing: 6

                RowLayout {
                    spacing: 8
                    Rectangle {
                        width: 10; height: 10; radius: 5
                        color: appWindow.daemonSynced    ? "#3fb950"
                               : appWindow.daemonRunning ? "#f0c040" : "#f85149"
                    }
                    MevaCoinComponents.TextPlain {
                        font.bold: true
                        font.pixelSize: 14
                        color: appWindow.daemonSynced    ? "#3fb950"
                               : appWindow.daemonRunning ? "#f0c040" : "#f85149"
                        text: {
                            if (appWindow.daemonSynced)  return qsTr("Nodo Sincronizzato") + translationManager.emptyString
                            if (appWindow.daemonRunning) return qsTr("Sincronizzazione in corso...") + translationManager.emptyString
                            return qsTr("Nodo Non Connesso") + translationManager.emptyString
                        }
                    }
                }

                MevaCoinComponents.TextPlain {
                    font.pixelSize: 12
                    color: MevaCoinComponents.Style.dimmedFontColor
                    text: persistentSettings.useRemoteNode
                          ? qsTr("Nodo remoto: ") + (persistentSettings.remoteNodeAddress || qsTr("non impostato"))
                          : qsTr("Nodo locale")
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }
        }

        // ── ACCESSO RAPIDO AL DEBUG ─────────────────────────
        MevaCoinComponents.StandardButton {
            Layout.topMargin: 16
            Layout.fillWidth: true
            small: false
            text: "🔍 " + qsTr("Monitor Connessioni (Debug)") + translationManager.emptyString
            onClicked: {
                if (middlePanel.settingsView.settingsStateViewState !== "Debug") {
                    middlePanel.settingsView.settingsStateViewState = "Debug";
                } else {
                    middlePanel.settingsView.settingsStateViewState = "Node";
                }
            }
        }

        // ── SEED NODES RAPIDI ────────────────────
        ColumnLayout {
            visible: true
            spacing: 8
            Layout.topMargin: 16
            Layout.fillWidth: true

            MevaCoinComponents.Label {
                fontSize: 14
                text: qsTr("Connetti a un Nodo MevaCoin") + translationManager.emptyString
            }

            Repeater {
                model: [
                    { name: "seed1 — 82.165.218.56",  addr: "82.165.218.56:18081"  },
                    { name: "seed2 — 87.106.40.193",  addr: "87.106.40.193:18081"  },
                    { name: "seed3 — 87.106.233.72",  addr: "87.106.233.72:18081"  }
                ]

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // Stato trusted locale per questo seed — default: true (abilitato)
                    property bool nodeTrusted: true

                    MevaCoinComponents.TextPlain {
                        Layout.fillWidth: true
                        font.pixelSize: 13
                        font.family: "monospace"
                        color: MevaCoinComponents.Style.defaultFontColor
                        text: modelData.name
                        wrapMode: Text.WrapAnywhere
                    }

                    // Toggle "Nodo fidato" — visibile sempre, abilitato di default
                    MevaCoinComponents.CheckBox {
                        id: trustedCheckBox
                        Layout.fillWidth: true
                        checked: nodeTrusted
                        text: qsTr("Nodo fidato") + translationManager.emptyString
                        onClicked: nodeTrusted = !nodeTrusted
                    }

                    // Bottone principale — visibile in modalità mobile
                    MevaCoinComponents.StandardButton {
                        small: true
                        visible: mobileMode
                        Layout.fillWidth: true
                        primary: remoteNodesModel.currentRemoteNode().address === modelData.addr && persistentSettings.useRemoteNode
                        text: (remoteNodesModel.currentRemoteNode().address === modelData.addr && persistentSettings.useRemoteNode)
                              ? ("✓ " + qsTr("Attivo") + translationManager.emptyString)
                              : (qsTr("Usa questo nodo") + translationManager.emptyString)
                        onClicked: {
                            var idx = remoteNodesModel.appendIfNotExists({
                                address: modelData.addr,
                                username: "",
                                password: "",
                                trusted: nodeTrusted
                            });
                            // Aggiorna trusted anche se il nodo era già salvato in lista
                            var node = remoteNodesModel.get(idx);
                            if (node && node.trusted !== nodeTrusted) {
                                remoteNodesModel.set(idx, {
                                    address: node.address,
                                    username: node.username,
                                    password: node.password,
                                    trusted: nodeTrusted
                                });
                            }
                            remoteNodesModel.applyRemoteNode(idx);
                            appWindow.showStatusMessage(qsTr("Connessione a ") + modelData.name + "...", 4)
                        }
                    }

                    // Riga alternativa — visibile in modalità desktop/tablet
                    RowLayout {
                        Layout.fillWidth: true
                        visible: !mobileMode
                        spacing: 8

                        MevaCoinComponents.TextPlain {
                            Layout.fillWidth: true
                            font.pixelSize: 13
                            font.family: "monospace"
                            color: MevaCoinComponents.Style.defaultFontColor
                            text: modelData.name
                            elide: Text.ElideRight
                        }

                        MevaCoinComponents.StandardButton {
                            small: true
                            primary: remoteNodesModel.currentRemoteNode().address === modelData.addr && persistentSettings.useRemoteNode
                            text: (remoteNodesModel.currentRemoteNode().address === modelData.addr && persistentSettings.useRemoteNode)
                                  ? (qsTr("Attivo") + translationManager.emptyString)
                                  : (qsTr("Usa") + translationManager.emptyString)
                            onClicked: {
                                var idx = remoteNodesModel.appendIfNotExists({
                                    address: modelData.addr,
                                    username: "",
                                    password: "",
                                    trusted: nodeTrusted
                                });
                                var node = remoteNodesModel.get(idx);
                                if (node && node.trusted !== nodeTrusted) {
                                    remoteNodesModel.set(idx, {
                                        address: node.address,
                                        username: node.username,
                                        password: node.password,
                                        trusted: nodeTrusted
                                    });
                                }
                                remoteNodesModel.applyRemoteNode(idx);
                                appWindow.showStatusMessage(qsTr("Connessione a ") + modelData.name + "...", 4)
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: MevaCoinComponents.Style.dividerColor
                        opacity: 0.4
                    }
                }
            }

            // ── SEPARATORE ───────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: MevaCoinComponents.Style.dividerColor
                opacity: 0.6
                Layout.topMargin: 8
            }

            // ── LISTA NODI SALVATI (con edit/trusted/rimuovi) ─
            MevaCoinComponents.Label {
                fontSize: 13
                text: qsTr("Nodi salvati") + translationManager.emptyString
                Layout.topMargin: 4
            }

            MevaCoinComponents.RemoteNodeList {
                Layout.fillWidth: true
                visible: persistentSettings.useRemoteNode
            }
        }


        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            color: "transparent"
            visible: !isAndroid

            Rectangle {
                id: localNodeDivider
                Layout.fillWidth: true
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: MevaCoinComponents.Style.dividerColor
                opacity: MevaCoinComponents.Style.dividerOpacity
            }

            Rectangle {
                visible: !persistentSettings.useRemoteNode
                Layout.fillHeight: true
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "darkgrey"
                width: 2
            }

            Rectangle {
                width: parent.width
                height: localNodeHeader.height + localNodeArea.contentHeight
                color: "transparent";
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: localNodeIcon
                    color: "transparent"
                    height: 32
                    width: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    MevaCoinComponents.Label {
                        fontSize: 32
                        text: FontAwesome.home
                        fontFamily: FontAwesome.fontFamilySolid
                        anchors.centerIn: parent
                        fontColor: MevaCoinComponents.Style.defaultFontColor
                        styleName: "Solid"
                    }
                }

                MevaCoinComponents.TextPlain {
                    id: localNodeHeader
                    anchors.left: localNodeIcon.right
                    anchors.leftMargin: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.top: parent.top
                    color: MevaCoinComponents.Style.defaultFontColor
                    opacity: MevaCoinComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    wrapMode: Text.WordWrap
                    text: qsTr("Local node") + translationManager.emptyString
                }

                Text {
                    id: localNodeArea
                    anchors.top: localNodeHeader.bottom
                    anchors.topMargin: 4
                    anchors.left: localNodeIcon.right
                    anchors.leftMargin: 14
                    color: MevaCoinComponents.Style.dimmedFontColor
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 15
                    horizontalAlignment: TextInput.AlignLeft
                    wrapMode: Text.WordWrap;
                    leftPadding: 0
                    topPadding: 0
                    text: qsTr("The blockchain is downloaded to your computer. Provides higher security and requires more local storage.") + translationManager.emptyString
                    width: parent.width - (localNodeIcon.width + localNodeIcon.anchors.leftMargin + anchors.leftMargin)
                }
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                enabled: persistentSettings.useRemoteNode
                onClicked: {
                    persistentSettings.useRemoteNode = false;
                    appWindow.disconnectRemoteNode();
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            color: "transparent"

            Rectangle {
                id: remoteNodeDivider
                Layout.fillWidth: true
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: MevaCoinComponents.Style.dividerColor
                opacity: MevaCoinComponents.Style.dividerOpacity
            }

            Rectangle {
                visible: persistentSettings.useRemoteNode
                Layout.fillHeight: true
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "darkgrey"
                width: 2
            }

            Rectangle {
                width: parent.width
                height: remoteNodeHeader.height + remoteNodeArea.contentHeight
                color: "transparent";
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: remoteNodeIcon
                    color: "transparent"
                    height: 32
                    width: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    MevaCoinComponents.Label {
                        fontSize: 28
                        text: FontAwesome.cloud
                        fontFamily: FontAwesome.fontFamilySolid
                        styleName: "Solid"
                        anchors.centerIn: parent
                        fontColor: MevaCoinComponents.Style.defaultFontColor
                    }
                }

                MevaCoinComponents.TextPlain {
                    id: remoteNodeHeader
                    anchors.left: remoteNodeIcon.right
                    anchors.leftMargin: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.top: parent.top
                    color: MevaCoinComponents.Style.defaultFontColor
                    opacity: MevaCoinComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    wrapMode: Text.WordWrap
                    text: qsTr("Remote node") + translationManager.emptyString
                }

                Text {
                    id: remoteNodeArea
                    anchors.top: remoteNodeHeader.bottom
                    anchors.topMargin: 4
                    anchors.left: remoteNodeIcon.right
                    anchors.leftMargin: 14
                    color: MevaCoinComponents.Style.dimmedFontColor
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 15
                    horizontalAlignment: TextInput.AlignLeft
                    wrapMode: Text.WordWrap;
                    leftPadding: 0
                    topPadding: 0
                    text: qsTr("Uses a third-party server to connect to the MevaCoin network. Less secure, but easier on your computer.") + translationManager.emptyString
                    width: parent.width - (remoteNodeIcon.width + remoteNodeIcon.anchors.leftMargin + anchors.leftMargin)
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    enabled: !persistentSettings.useRemoteNode
                    onClicked: {
                        appWindow.connectRemoteNode();
                    }
                }
            }

            Rectangle {
                id: localNodeBottomDivider
                Layout.fillWidth: true
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: MevaCoinComponents.Style.dividerColor
                opacity: MevaCoinComponents.Style.dividerOpacity
            }
        }

        MevaCoinComponents.WarningBox {
            Layout.topMargin: 46
            text: qsTr("To find a remote node, type 'MevaCoin remote node' into your favorite search engine. Please ensure the node is run by a trusted third-party.") + translationManager.emptyString
            visible: persistentSettings.useRemoteNode
        }

        MevaCoinComponents.RemoteNodeList {
            Layout.fillWidth: true
            Layout.topMargin: 26
            visible: persistentSettings.useRemoteNode
        }

        ColumnLayout {
            id: localNodeLayout
            spacing: 20
            Layout.topMargin: 40
            visible: !persistentSettings.useRemoteNode

            MevaCoinComponents.StandardButton {
                small: true
                text: (appWindow.daemonRunning ? qsTr("Stop daemon") : qsTr("Start daemon")) + translationManager.emptyString
                onClicked: {
                    if (appWindow.daemonRunning) {
                        appWindow.stopDaemon();
                    } else {
                        persistentSettings.daemonFlags = daemonFlags.text;
                        appWindow.startDaemon(persistentSettings.daemonFlags);
                    }
                }
            }

            RowLayout {
                MevaCoinComponents.LineEditMulti {
                    id: blockchainFolder
                    Layout.preferredWidth: 200
                    Layout.fillWidth: true
                    fontSize: 15
                    labelFontSize: 14
                    property string style: "<style type='text/css'>a {cursor:pointer;text-decoration: none; color: #FF6C3C}</style>"
                    labelText: qsTr("Blockchain location") + style + " <a href='#'> (%1)</a>".arg(qsTr("Change")) + translationManager.emptyString
                    labelButtonText: qsTr("Reset") + translationManager.emptyString
                    labelButtonVisible: text
                    placeholderText: qsTr("(default)") + translationManager.emptyString
                    placeholderFontSize: 15
                    readOnly: true
                    text: persistentSettings.blockchainDataDir
                    addressValidation: false
                    onInputLabelLinkActivated: {
                        if(persistentSettings.blockchainDataDir !== ""){
                            blockchainFileDialog.folder = "file://" + persistentSettings.blockchainDataDir;
                        }
                        blockchainFileDialog.open();
                        blockchainFolder.focus = true;
                    }
                    onLabelButtonClicked: persistentSettings.blockchainDataDir = ""
                }
            }

            MevaCoinComponents.LineEditMulti {
                id: daemonFlags
                Layout.fillWidth: true
                labelFontSize: 14
                fontSize: 15
                wrapMode: Text.WrapAnywhere
                labelText: qsTr("Daemon startup flags") + translationManager.emptyString
                placeholderText: qsTr("(optional)") + translationManager.emptyString
                placeholderFontSize: 15
                text: persistentSettings.daemonFlags
                addressValidation: false
                error: text.match(/(^|\s)--(data-dir|bootstrap-daemon-address|non-interactive)/)
                onEditingFinished: {
                    if (!daemonFlags.error) {
                        persistentSettings.daemonFlags = daemonFlags.text;
                    }
                }
            }

            MevaCoinComponents.LineEditMulti {
                id: daemonUsername
                Layout.fillWidth: true
                labelFontSize: 14
                fontSize: 15
                labelText: qsTr("Daemon RPC username") + translationManager.emptyString
                placeholderText: qsTr("(optional)") + translationManager.emptyString
                placeholderFontSize: 15
                text: persistentSettings.daemonUsername
                addressValidation: false
                onEditingFinished: {
                    persistentSettings.daemonUsername = daemonUsername.text;
                }
            }

            MevaCoinComponents.LineEdit {
                id: daemonPassword
                Layout.fillWidth: true
                labelFontSize: 14
                fontSize: 15
                labelText: qsTr("Daemon RPC password") + translationManager.emptyString
                placeholderText: qsTr("(optional)") + translationManager.emptyString
                placeholderFontSize: 15
                text: persistentSettings.daemonPassword
                password: true
                onEditingFinished: {
                    persistentSettings.daemonPassword = daemonPassword.text;
                }
            }

            RowLayout {
                visible: !persistentSettings.useRemoteNode

                ColumnLayout {
                    Layout.fillWidth: true

                    MevaCoinComponents.RemoteNodeEdit {
                        id: bootstrapNodeEdit
                        Layout.minimumWidth: (typeof isAndroid !== "undefined" && isAndroid) ? 200 : 100
                        Layout.bottomMargin: 20

                        daemonAddrLabelText: qsTr("Bootstrap Address") + translationManager.emptyString
                        daemonPortLabelText: qsTr("Bootstrap Port") + translationManager.emptyString
                        initialAddress: persistentSettings.bootstrapNodeAddress
                        onEditingFinished: {
                            if (daemonAddrText == "auto") {
                                persistentSettings.bootstrapNodeAddress = daemonAddrText;
                            } else {
                                persistentSettings.bootstrapNodeAddress = daemonAddrText ? bootstrapNodeEdit.getAddress() : "";
                            }
                            console.log("setting bootstrap node to " + persistentSettings.bootstrapNodeAddress)
                        }
                    }
                }
            }
        }
    }
}
