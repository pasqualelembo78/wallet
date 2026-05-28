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
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import mevacoinComponents.Clipboard 1.0
import "../version.js" as Version
import "../components" as MevaCoinComponents
import "." 1.0


Rectangle {
    id: page
    property bool viewOnly: false
    property int keysHeight: mainLayout.height + 100 // Ensure sufficient height for QR code, even in minimum width window case.

    color: "transparent"

    Clipboard { id: clipboard }

    ColumnLayout {
        id: mainLayout

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        anchors.margins: 20
        anchors.topMargin: 40

        spacing: 30
        Layout.fillWidth: true

        // Avviso globale chiavi
        MevaCoinComponents.WarningBox {
            text: qsTr("WARNING: Do not reuse your MevaCoin keys on another fork, UNLESS this fork has key reuse mitigations built in. Doing so will harm your privacy.") + translationManager.emptyString;
        }

        //! Mnemonic seed
        ColumnLayout {
            Layout.fillWidth: true

            MevaCoinComponents.Label {
                Layout.fillWidth: true
                fontSize: 22
                Layout.topMargin: 10
                text: qsTr("Mnemonic seed") + translationManager.emptyString
            }

            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: MevaCoinComponents.Style.dividerColor
                opacity: MevaCoinComponents.Style.dividerOpacity
                Layout.bottomMargin: 10
            }

            MevaCoinComponents.WarningBox {
                text: qsTr("WARNING: Copying your seed to clipboard can expose you to malicious software, which may record your seed and steal your MevaCoin. Please write down your seed manually.") + translationManager.emptyString
            }

            MevaCoinComponents.LineEditMulti {
                id: seedText
                spacing: 0
                copyButton: true
                addressValidation: false
                readOnly: true
                wrapMode: Text.WordWrap
                fontColor: MevaCoinComponents.Style.defaultFontColor
            }
        }

        // Wallet restore height
        ColumnLayout {
            Layout.fillWidth: true

            MevaCoinComponents.Label {
                Layout.fillWidth: true
                fontSize: 22
                Layout.topMargin: 10
                text: qsTr("Wallet restore height") + translationManager.emptyString
            }

            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: MevaCoinComponents.Style.dividerColor
                opacity: MevaCoinComponents.Style.dividerOpacity
                Layout.bottomMargin: 10
            }

            MevaCoinComponents.LineEdit {
                Layout.fillWidth: true
                id: walletCreationHeight
                readOnly: true
                copyButton: true
                labelText: qsTr("Block #") + translationManager.emptyString
                fontSize: 16
            }
        }

        // Primary address & Keys
        ColumnLayout {
            Layout.fillWidth: true

            MevaCoinComponents.Label {
                Layout.fillWidth: true
                fontSize: 22
                Layout.topMargin: 10
                text: qsTr("Primary address & Keys") + translationManager.emptyString
            }
            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: MevaCoinComponents.Style.dividerColor
                opacity: MevaCoinComponents.Style.dividerOpacity
                Layout.bottomMargin: 10
            }
            MevaCoinComponents.LineEditMulti {
                Layout.fillWidth: true
                id: primaryAddress
                readOnly: true
                copyButton: true
                wrapMode: Text.Wrap
                labelText: qsTr("Primary address") + translationManager.emptyString
                fontSize: 16
            }
            MevaCoinComponents.LineEdit {
                Layout.fillWidth: true
                Layout.topMargin: 25
                id: secretViewKey
                readOnly: true
                copyButton: true
                labelText: qsTr("Secret view key") + translationManager.emptyString
                fontSize: 16
            }
            MevaCoinComponents.LineEdit {
                Layout.fillWidth: true
                Layout.topMargin: 25
                id: publicViewKey
                readOnly: true
                copyButton: true
                labelText: qsTr("Public view key") + translationManager.emptyString
                fontSize: 16
            }
            MevaCoinComponents.LineEdit {
                Layout.fillWidth: true
                Layout.topMargin: 25
                id: secretSpendKey
                readOnly: true
                copyButton: true
                labelText: qsTr("Secret spend key") + translationManager.emptyString
                fontSize: 16
            }
            MevaCoinComponents.LineEdit {
                Layout.fillWidth: true
                Layout.topMargin: 25
                id: publicSpendKey
                readOnly: true
                copyButton: true
                labelText: qsTr("Public spend key") + translationManager.emptyString
                fontSize: 16
            }
        }

        // Export wallet (QR code)
        ColumnLayout {
            Layout.fillWidth: true

            MevaCoinComponents.Label {
                Layout.fillWidth: true
                fontSize: 22
                Layout.topMargin: 10
                text: qsTr("Export wallet") + translationManager.emptyString
            }
            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: MevaCoinComponents.Style.dividerColor
                opacity: MevaCoinComponents.Style.dividerOpacity
                Layout.bottomMargin: 10
            }

            ColumnLayout {
                MevaCoinComponents.RadioButton {
                    id: showFullQr
                    enabled: !this.checked
                    checked: fullWalletQRCode.visible
                    text: qsTr("Spendable Wallet") + translationManager.emptyString
                    onClicked: {
                        viewOnlyQRCode.visible = false
                        showViewOnlyQr.checked = false
                    }
                }
                MevaCoinComponents.RadioButton {
                    enabled: !this.checked
                    id: showViewOnlyQr
                    checked: viewOnlyQRCode.visible
                    text: qsTr("View Only Wallet") + translationManager.emptyString
                    onClicked: {
                        viewOnlyQRCode.visible = true
                        showFullQr.checked = false
                    }
                }
                Layout.bottomMargin: 30
            }

            Image {
                visible: !viewOnlyQRCode.visible
                id: fullWalletQRCode
                Layout.fillWidth: true
                Layout.minimumHeight: 180
                smooth: false
                fillMode: Image.PreserveAspectFit
            }

            Image {
                visible: false
                id: viewOnlyQRCode
                Layout.fillWidth: true
                Layout.minimumHeight: 180
                smooth: false
                fillMode: Image.PreserveAspectFit
            }

            MevaCoinComponents.TextPlain {
                Layout.fillWidth: true
                font.bold: true
                font.pixelSize: 16
                color: MevaCoinComponents.Style.defaultFontColor
                text: (viewOnlyQRCode.visible) ? qsTr("View Only Wallet") + translationManager.emptyString : qsTr("Spendable Wallet") + translationManager.emptyString
                horizontalAlignment: Text.AlignHCenter
            }

            MevaCoinComponents.StandardButton {
                small: true
                text: qsTr("Done") + translationManager.emptyString
                onClicked: {
                    loadPage("Settings")
                }
                Layout.alignment: Qt.AlignCenter
                width: 135
            }
        }

        // ── EXPORT WALLET FILE ─────────────────────────────────
        // CORRETTO: ora e' DENTRO mainLayout (era fuori, causava overlap)
        ColumnLayout {
            id: exportWalletMvc
            Layout.fillWidth: true
            spacing: 12

            MevaCoinComponents.Label {
                Layout.fillWidth: true
                fontSize: 22
                Layout.topMargin: 10
                text: qsTr("Export wallet file") + translationManager.emptyString
            }
            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: MevaCoinComponents.Style.dividerColor
                opacity: MevaCoinComponents.Style.dividerOpacity
                Layout.bottomMargin: 10
            }

            MevaCoinComponents.TextPlain {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: MevaCoinComponents.Style.dimmedFontColor
                text: qsTr("Copy the wallet files to the Downloads folder to open them with mvcwallet or transfer to another device.") + translationManager.emptyString
            }

            MevaCoinComponents.LineEdit {
                id: walletFilePath
                Layout.fillWidth: true
                readOnly: true
                copyButton: true
                labelText: qsTr("Wallet file path") + translationManager.emptyString
                fontSize: 13
                text: ""
            }

            Rectangle {
                id: exportStatusBox
                Layout.fillWidth: true
                height: exportStatusText.implicitHeight + 16
                color: exportSuccess ? "#1a3a1a" : "#3a1a1a"
                radius: 4
                visible: exportStatusText.text !== ""
                property bool exportSuccess: true

                MevaCoinComponents.TextPlain {
                    id: exportStatusText
                    anchors.fill: parent
                    anchors.margins: 8
                    wrapMode: Text.Wrap
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 13
                    color: exportStatusBox.exportSuccess ? "#55ff55" : "#ff6666"
                    text: ""
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MevaCoinComponents.StandardButton {
                    id: exportWalletBtn
                    small: true
                    text: qsTr("Copy to Downloads") + translationManager.emptyString
                    enabled: currentWallet !== undefined && currentWallet !== null
                    onClicked: {
                        var walletPath = appWindow.accountsDir + persistentSettings.wallet_path;
                        var walletName = persistentSettings.wallet_path.split("/").pop().split("\\").pop();
                        if (walletName === "") walletName = "mevacoin_wallet";

                        if (isAndroid) {
                            var opened = oshelper.openFile(walletPath + ".keys");
                            if (opened) {
                                exportStatusBox.exportSuccess = true;
                                exportStatusText.text = qsTr("Wallet .keys file shared via Android. Use the share dialog to save or send it.") + translationManager.emptyString;
                            } else {
                                exportStatusBox.exportSuccess = false;
                                exportStatusText.text = qsTr("Could not open share dialog. Wallet file is at: ") + walletPath + ".keys" + translationManager.emptyString;
                            }
                        } else {
                            oshelper.openContainingFolder(walletPath);
                            exportStatusBox.exportSuccess = true;
                            exportStatusText.text = qsTr("Wallet folder opened in file manager.") + translationManager.emptyString;
                        }
                    }
                }

                MevaCoinComponents.StandardButton {
                    id: shareWalletBtn
                    small: true
                    visible: isAndroid
                    text: qsTr("Share wallet") + translationManager.emptyString
                    enabled: currentWallet !== undefined && currentWallet !== null
                    onClicked: {
                        var walletPath = appWindow.accountsDir + persistentSettings.wallet_path;
                        var shared = oshelper.openFile(walletPath);
                        if (!shared) {
                            exportStatusBox.exportSuccess = false;
                            exportStatusText.text = qsTr("Could not share wallet file. Path: ") + walletPath + translationManager.emptyString;
                        } else {
                            exportStatusBox.exportSuccess = true;
                            exportStatusText.text = qsTr("Share dialog opened for wallet file.") + translationManager.emptyString;
                        }
                    }
                }
            }
        }
        // ── fine EXPORT WALLET FILE ────────────────────────────

    } // fine mainLayout

    // fires on every page load
    function onPageCompleted() {
        console.log("keys page loaded");
        var wp = appWindow.accountsDir + persistentSettings.wallet_path;
        walletFilePath.text = wp;

        primaryAddress.text = currentWallet.address(0, 0)
        walletCreationHeight.text = currentWallet.walletCreationHeight
        secretViewKey.text = currentWallet.secretViewKey
        publicViewKey.text = currentWallet.publicViewKey
        secretSpendKey.text = (!currentWallet.viewOnly) ? currentWallet.secretSpendKey : ""
        publicSpendKey.text = currentWallet.publicSpendKey

        seedText.text = currentWallet.seed === "" ? qsTr("Mnemonic seed protected by hardware device.") + translationManager.emptyString : currentWallet.seed

        if(typeof currentWallet != "undefined") {
            viewOnlyQRCode.source = "image://qrcode/mevacoin_wallet:" + currentWallet.address(0, 0) + "?view_key="+currentWallet.secretViewKey+"&height="+currentWallet.walletCreationHeight
            fullWalletQRCode.source = viewOnlyQRCode.source +"&spend_key="+currentWallet.secretSpendKey

            if(currentWallet.viewOnly) {
                viewOnlyQRCode.visible = true
                showFullQr.visible = false
                showViewOnlyQr.visible = false
                seedText.text = qsTr("(View Only Wallet - No mnemonic seed available)") + translationManager.emptyString
                secretSpendKey.text = qsTr("(View Only Wallet - No secret spend key available)") + translationManager.emptyString
            }
            if(appWindow.currentWallet.isHwBacked() === true) {
                showFullQr.visible = false
                viewOnlyQRCode.visible = true
                showViewOnlyQr.visible = false
                secretSpendKey.text = qsTr("(Hardware Device Wallet - No secret spend key available)") + translationManager.emptyString
            }
        }
    }

    Component.onCompleted: {
    }
}
