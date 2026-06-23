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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import FontAwesome 1.0

import "../../js/Utils.js" as Utils
import "../../components" as MevaCoinComponents
import mevacoinComponents.Clipboard 1.0

Rectangle {
    color: "transparent"
    Layout.fillWidth: true
    property alias settingsHeight: settingsWallet.height

    Clipboard { id: clipboard }

    ColumnLayout {
        id: settingsWallet
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 0
        spacing: 0

        MevaCoinComponents.SettingsListItem {
            iconText: FontAwesome.lock
            description: qsTr("Locks the wallet on demand.") + translationManager.emptyString
            title: qsTr("Lock this wallet") + translationManager.emptyString
            symbol: (isMac ? "⌃" : qsTr("Ctrl+")) + "L" + translationManager.emptyString
            onClicked: appWindow.lock();
        }

        MevaCoinComponents.SettingsListItem {
            iconText: FontAwesome.userLock
            description: qsTr("Locks the app and returns to the login screen.") + translationManager.emptyString
            title: qsTr("Lock app") + translationManager.emptyString

            onClicked: {
                appWindow.closeWallet()
                rootItem.state = "login"
                loginScreen.isSetup = false
            }
        }

        MevaCoinComponents.SettingsListItem {
            iconText: FontAwesome.signOutAlt
            description: qsTr("Logs out of this wallet.") + translationManager.emptyString
            title: qsTr("Close this wallet") + translationManager.emptyString

            onClicked: appWindow.showWizard()
        }

        MevaCoinComponents.SettingsListItem {
            iconText: FontAwesome.eye
            description: qsTr("Creates a new wallet that can only view and initiate transactions, but requires a spendable wallet to sign transactions before sending.") + translationManager.emptyString
            title: qsTr("Create a view-only wallet") + translationManager.emptyString
            visible: !appWindow.viewOnly && (currentWallet ? !currentWallet.isLedger() : true)

            onClicked: {
                var newPath = currentWallet.path + "_viewonly";
                if (currentWallet.createViewOnly(newPath, appWindow.walletPassword)) {
                    console.log("view only wallet created in " + newPath);
                    informationPopup.title  = qsTr("Success") + translationManager.emptyString;
                    informationPopup.text = qsTr('The view only wallet has been created with the same password as the current wallet. You can open it by closing this current wallet, clicking the "Open wallet from file" option, and selecting the view wallet in: \n%1\nYou can change the password in the wallet settings.').arg(newPath);
                    informationPopup.open()
                    informationPopup.onCloseCallback = null
                } else {
                    informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                    informationPopup.text = currentWallet.errorString;
                    informationPopup.open()
                }
            }
        }

        MevaCoinComponents.SettingsListItem {
            iconText: FontAwesome.key
            description: qsTr("Store this information safely to recover your wallet in the future.") + translationManager.emptyString
            title: qsTr("Show seed & keys") + translationManager.emptyString

            onClicked: {
                Utils.showSeedPage();
            }
        }

        MevaCoinComponents.SettingsListItem {
            enabled: leftPanel.progressBar.fillLevel == 100
            iconText: FontAwesome.repeat
            description: qsTr("Use this feature if you think the shown balance is not accurate.") + translationManager.emptyString
            title: qsTr("Rescan wallet balance") + translationManager.emptyString
            visible: appWindow.walletMode >= 2

            onClicked: {
                if (!currentWallet.rescanSpent()) {
                    console.error("Error: ", currentWallet.errorString);
                    informationPopup.title = qsTr("Error") + translationManager.emptyString;
                    if (currentWallet.errorString == "Rescan spent can only be used with a trusted daemon") {
                        informationPopup.text = qsTr("Error: ") + qsTr("Rescan spent can only be used with a trusted remote node. If you trust the current node you are connected to (%1), you can mark it as trusted in Settings > Node page.").arg(remoteNodesModel.currentRemoteNode().address) + translationManager.emptyString;
                    } else {
                        informationPopup.text = qsTr("Error: ") + currentWallet.errorString;
                    }
                    informationPopup.icon  = StandardIcon.Critical
                    informationPopup.onCloseCallback = null
                    informationPopup.open();
                } else {
                    informationPopup.title = qsTr("Information") + translationManager.emptyString
                    informationPopup.text  = qsTr("Successfully rescanned spent outputs.") + translationManager.emptyString
                    informationPopup.icon  = StandardIcon.Information
                    informationPopup.onCloseCallback = null
                    informationPopup.open();
                }
            }
        }

        MevaCoinComponents.SettingsListItem {
            enabled: leftPanel.progressBar.fillLevel == 100
            iconText: FontAwesome.magnifyingGlass
            description: qsTr("Use this feature if a transaction is missing in your wallet history. This will expose the transaction ID to the remote node, which can harm your privacy.") + translationManager.emptyString
            title: qsTr("Scan transaction") + translationManager.emptyString

            onClicked: {
                inputDialog.labelText = qsTr("Enter a transaction ID:") + translationManager.emptyString;
                inputDialog.onAcceptedCallback = function() {
                    var txid = inputDialog.inputText.trim();
                    if (currentWallet.scanTransactions([txid])) {
                        updateBalance();
                        appWindow.showStatusMessage(qsTr("Transaction successfully scanned"), 3);
                    } else {
                        console.error("Error: ", currentWallet.errorString);
                        if (currentWallet.errorString == "The wallet has already seen 1 or more recent transactions than the scanned tx") {
                            informationPopup.title = qsTr("Error") + translationManager.emptyString;
                            informationPopup.text = qsTr("The wallet has already seen 1 or more recent transactions than the scanned transaction.\n\nIn order to rescan the transaction, you can re-sync your wallet by resetting the wallet restore height in the Settings > Info page. Make sure to use a restore height from before your wallet's earliest transaction.") + translationManager.emptyString;
                            informationPopup.icon = StandardIcon.Critical
                            informationPopup.onCloseCallback = null
                            informationPopup.open();
                        } else {
                            appWindow.showStatusMessage(qsTr("Failed to scan transaction") + ": " + currentWallet.errorString, 5);
                        }
                    }
                }
                inputDialog.onRejectedCallback = null;
                inputDialog.open()
            }
        }

        MevaCoinComponents.SettingsListItem {
            iconText: FontAwesome.ellipsisH
            description: qsTr("Change the password of your wallet.") + translationManager.emptyString
            title: qsTr("Change wallet password") + translationManager.emptyString

            onClicked: {
                passwordDialog.onAcceptedCallback = function() {
                    if(appWindow.walletPassword === passwordDialog.password){
                        passwordDialog.openNewPasswordDialog()
                    } else {
                        informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                        informationPopup.text = qsTr("Wrong password") + translationManager.emptyString;
                        informationPopup.open()
                        informationPopup.onCloseCallback = function() {
                            passwordDialog.open()
                        }
                    }
                }
                passwordDialog.onRejectedCallback = null;
                passwordDialog.open()
            }
        }

        MevaCoinComponents.SettingsListItem {
            iconText: FontAwesome.userCog
            description: qsTr("Change the username or password used to access this app.") + translationManager.emptyString
            title: qsTr("Change app access credentials") + translationManager.emptyString

            onClicked: {
                inputDialog.labelText = qsTr("Enter current password to change credentials:") + translationManager.emptyString;
                inputDialog.inputText = ""
                inputDialog.passwordMode = true
                inputDialog.onAcceptedCallback = function() {
                    if (inputDialog.inputText === persistentSettings.loginPassword) {
                        persistentSettings.loginUsername = ""
                        persistentSettings.loginPassword = ""
                        informationPopup.title  = qsTr("Credentials reset") + translationManager.emptyString;
                        informationPopup.text = qsTr("App credentials have been reset. You will be asked to set new ones on next app start.") + translationManager.emptyString;
                        informationPopup.icon  = StandardIcon.Information
                        informationPopup.onCloseCallback = null
                        informationPopup.open()
                    } else {
                        informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                        informationPopup.text = qsTr("Wrong password") + translationManager.emptyString;
                        informationPopup.icon  = StandardIcon.Critical
                        informationPopup.onCloseCallback = null
                        informationPopup.open()
                    }
                }
                inputDialog.onRejectedCallback = null;
                inputDialog.open()
            }
        }

        // ── Save / forget password on device ─────────────────────────────────
        MevaCoinComponents.SettingsListItem {
            iconText: persistentSettings.savePasswordOnDevice ? FontAwesome.unlockAlt : FontAwesome.lock
            title: persistentSettings.savePasswordOnDevice
                ? qsTr("Forget saved password") + translationManager.emptyString
                : qsTr("Save password on this device") + translationManager.emptyString
            description: persistentSettings.savePasswordOnDevice
                ? qsTr("The password saved on this device will be deleted. You will be asked for it next time.") + translationManager.emptyString
                : qsTr("Save your wallet password locally so you are never asked for it again on this device.") + translationManager.emptyString

            onClicked: {
                if (persistentSettings.savePasswordOnDevice) {
                    // Forget: clear saved password
                    persistentSettings.savePasswordOnDevice = false;
                    persistentSettings.savedWalletPassword = "";
                    informationPopup.title = qsTr("Password removed") + translationManager.emptyString;
                    informationPopup.text  = qsTr("Saved password has been deleted from this device. You will be asked for your password on next access.") + translationManager.emptyString;
                    informationPopup.open();
                } else {
                    // Save: verify current password first, then save
                    passwordDialog.onAcceptedCallback = function() {
                        if (appWindow.walletPassword === passwordDialog.password) {
                            persistentSettings.savePasswordOnDevice = true;
                            persistentSettings.savedWalletPassword = passwordDialog.password;
                            passwordDialog.close();
                            informationPopup.title = qsTr("Password saved") + translationManager.emptyString;
                            informationPopup.text  = qsTr("Your password is now saved on this device. You will not be asked for it again.") + translationManager.emptyString;
                            informationPopup.open();
                        } else {
                            passwordDialog.showError(qsTr("Wrong password") + translationManager.emptyString);
                        }
                    }
                    passwordDialog.onRejectedCallback = null;
                    passwordDialog.open();
                }
            }
        }

        MevaCoinComponents.SettingsListItem {
            iconText: FontAwesome.cashRegister
            description: qsTr("Receive MevaCoin for your business, easily.") + translationManager.emptyString
            title: qsTr("Enter merchant mode") + translationManager.emptyString

            onClicked: {
                middlePanel.state = "Merchant";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }
        }

        // ── DOWNLOAD WALLET FILE (per mvcwallet) ─────────────────
        MevaCoinComponents.SettingsListItem {
            id: downloadWalletItem
            iconText: FontAwesome.download
            isLast: true
            title: qsTr("Download wallet file") + translationManager.emptyString
            description: qsTr("Export the wallet .keys file to use with mvcwallet on your server.") + translationManager.emptyString
            visible: isAndroid
            onClicked: { downloadWalletDialog.open() }
        }

        Rectangle {
            id: downloadWalletDialog
            visible: false
            z: 999
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.75)

            // Percorso wallet senza duplicare accountsDir.
            // Su Android wallet_path è già assoluto (inizia con /).
            function resolvedWalletPath() {
                var wp = persistentSettings.wallet_path;
                return (wp.charAt(0) === "/") ? wp : (appWindow.accountsDir + wp);
            }

            // Genera nome default: mvcwallet_YYYYMMDD_HHmm
            function defaultWalletName() {
                var now = new Date();
                var yyyy = now.getFullYear();
                var MM   = ("0" + (now.getMonth() + 1)).slice(-2);
                var dd   = ("0" + now.getDate()).slice(-2);
                var HH   = ("0" + now.getHours()).slice(-2);
                var mm   = ("0" + now.getMinutes()).slice(-2);
                return "mvcwallet_" + yyyy + MM + dd + "_" + HH + mm;
            }

            function open() {
                visible = true;
                statusText.text = "";
                statusText.color = "#ffffff";
                customNameField.text = defaultWalletName();
            }
            function close() { visible = false }

            MouseArea { anchors.fill: parent; onClicked: downloadWalletDialog.close() }

            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width - 32, 400)
                height: dlgCol.implicitHeight + 40
                color: MevaCoinComponents.Style.blackTheme ? "#1a1a1a" : "#ffffff"
                radius: 10
                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    id: dlgCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    spacing: 14

                    MevaCoinComponents.TextPlain {
                        Layout.fillWidth: true
                        font.pixelSize: 17
                        font.bold: true
                        color: MevaCoinComponents.Style.defaultFontColor
                        text: qsTr("Save wallet to Downloads") + translationManager.emptyString
                    }

                    MevaCoinComponents.TextPlain {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        font.pixelSize: 13
                        color: MevaCoinComponents.Style.dimmedFontColor
                        text: qsTr("The wallet files will be copied to your Downloads folder and can be opened with mvcwallet.") + translationManager.emptyString
                    }

                    // Campo nome personalizzato
                    MevaCoinComponents.TextPlain {
                        Layout.fillWidth: true
                        font.pixelSize: 12
                        font.bold: true
                        color: MevaCoinComponents.Style.defaultFontColor
                        text: qsTr("File name:") + translationManager.emptyString
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            color: MevaCoinComponents.Style.blackTheme ? "#2a2a2a" : "#f5f5f5"
                            radius: 4
                            border.color: customNameField.activeFocus
                                ? MevaCoinComponents.Style.orange
                                : (MevaCoinComponents.Style.blackTheme ? "#555555" : "#cccccc")
                            border.width: customNameField.activeFocus ? 2 : 1

                            TextInput {
                                id: customNameField
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                anchors.topMargin: 0
                                anchors.bottomMargin: 0
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 13
                                color: MevaCoinComponents.Style.defaultFontColor
                                selectionColor: MevaCoinComponents.Style.orange
                                selectedTextColor: "#ffffff"
                                clip: true
                                selectByMouse: true
                            }
                        }

                        // Pulsante reset al nome default
                        Rectangle {
                            width: 36
                            height: 40
                            color: resetNameBtn.containsMouse
                                ? (MevaCoinComponents.Style.blackTheme ? "#3a3a3a" : "#e0e0e0")
                                : (MevaCoinComponents.Style.blackTheme ? "#2a2a2a" : "#f5f5f5")
                            radius: 4
                            border.color: MevaCoinComponents.Style.blackTheme ? "#555555" : "#cccccc"
                            border.width: 1

                            MevaCoinComponents.TextPlain {
                                anchors.centerIn: parent
                                font.pixelSize: 16
                                color: MevaCoinComponents.Style.dimmedFontColor
                                text: "↺"
                            }

                            MouseArea {
                                id: resetNameBtn
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: customNameField.text = downloadWalletDialog.defaultWalletName()
                            }
                        }
                    }

                    // Hint sotto il campo
                    MevaCoinComponents.TextPlain {
                        Layout.fillWidth: true
                        font.pixelSize: 11
                        color: MevaCoinComponents.Style.dimmedFontColor
                        text: qsTr("Tap ↺ to restore the default name") + translationManager.emptyString
                    }

                    // Mostra destinazione aggiornata in tempo reale
                    Rectangle {
                        Layout.fillWidth: true
                        height: dstLabel.implicitHeight + 10
                        color: MevaCoinComponents.Style.blackTheme ? "#2a2a2a" : "#f0f0f0"
                        radius: 4
                        MevaCoinComponents.TextPlain {
                            id: dstLabel
                            anchors.fill: parent; anchors.margins: 5
                            wrapMode: Text.WrapAnywhere
                            font.pixelSize: 11
                            color: MevaCoinComponents.Style.dimmedFontColor
                            text: {
                                var finalName = customNameField.text.trim() !== ""
                                    ? customNameField.text.trim()
                                    : downloadWalletDialog.defaultWalletName();
                                return qsTr("Destination: ") + oshelper.downloadLocation() + "/" + finalName + ".keys"
                            }
                        }
                    }

                    // Stato operazione
                    MevaCoinComponents.TextPlain {
                        id: statusText
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        font.pixelSize: 13
                        font.bold: true
                        color: "#ffffff"
                        text: ""
                        visible: text !== ""
                    }

                    // Pulsante principale
                    MevaCoinComponents.StandardButton {
                        id: downloadBtn
                        text: qsTr("Save to Downloads") + translationManager.emptyString
                        Layout.fillWidth: true
                        onClicked: {
                            downloadBtn.enabled = false;
                            statusText.color = "#aaaaaa";
                            statusText.text = qsTr("Copying…") + translationManager.emptyString;

                            var src = downloadWalletDialog.resolvedWalletPath();
                            var finalName = customNameField.text.trim() !== ""
                                ? customNameField.text.trim()
                                : downloadWalletDialog.defaultWalletName();
                            var dst = oshelper.copyToDownloads(src, finalName);

                            if (dst !== "") {
                                statusText.color = "#44cc66";
                                statusText.text = "✓ " + qsTr("Saved! Open your Downloads folder to find the wallet files.") + translationManager.emptyString;
                            } else {
                                statusText.color = "#ff5555";
                                statusText.text = "✗ " + qsTr("Copy failed. Check storage permissions.") + translationManager.emptyString;
                            }
                            downloadBtn.enabled = true;
                        }
                    }

                    MevaCoinComponents.StandardButton {
                        text: qsTr("Close") + translationManager.emptyString
                        small: true
                        Layout.alignment: Qt.AlignRight
                        onClicked: downloadWalletDialog.close()
                    }
                }
            }
        }
        // ─────────────────────────────────────────────────────────
    }

    Component.onCompleted: {
        console.log('SettingsWallet loaded');
    }
}

