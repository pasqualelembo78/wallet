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

import "../components" as MevaCoinComponents

Item {
    id: root
    anchors.fill: parent

    property bool isSetup: false

    signal loginSucceeded()

    Rectangle {
        anchors.fill: parent
        color: MevaCoinComponents.Style.blackTheme ? "#1a1a2e" : "#f0f4f8"

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.85, 400)
            spacing: 20

            Image {
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:///images/mevacoinIcon-64x64.png"
                sourceSize.width: 64
                sourceSize.height: 64
                fillMode: Image.PreserveAspectFit
            }

            MevaCoinComponents.TextPlain {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 24
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                text: isSetup
                    ? qsTr("Set up app access") + translationManager.emptyString
                    : qsTr("App access") + translationManager.emptyString
            }

            MevaCoinComponents.TextPlain {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                text: isSetup
                    ? qsTr("Create credentials to protect access to this app. These are separate from your wallet password.") + translationManager.emptyString
                    : qsTr("Enter your credentials to access the app.") + translationManager.emptyString
                visible: isSetup
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 6
                color: MevaCoinComponents.Style.blackTheme ? "#2a2a3e" : "#ffffff"
                border.color: usernameField.activeFocus
                    ? MevaCoinComponents.Style.orange
                    : (MevaCoinComponents.Style.blackTheme ? "#3a3a4e" : "#d0d0d0")
                border.width: usernameField.activeFocus ? 2 : 1

                TextInput {
                    id: usernameField
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 16
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    color: MevaCoinComponents.Style.defaultFontColor
                    selectionColor: MevaCoinComponents.Style.orange
                    selectedTextColor: "#ffffff"
                    selectByMouse: true
                    placeholderText: qsTr("Username") + translationManager.emptyString
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 6
                color: MevaCoinComponents.Style.blackTheme ? "#2a2a3e" : "#ffffff"
                border.color: passwordField.activeFocus
                    ? MevaCoinComponents.Style.orange
                    : (MevaCoinComponents.Style.blackTheme ? "#3a3a4e" : "#d0d0d0")
                border.width: passwordField.activeFocus ? 2 : 1

                TextInput {
                    id: passwordField
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 16
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    color: MevaCoinComponents.Style.defaultFontColor
                    selectionColor: MevaCoinComponents.Style.orange
                    selectedTextColor: "#ffffff"
                    selectByMouse: true
                    echoMode: TextInput.Password
                    placeholderText: qsTr("Password") + translationManager.emptyString
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 6
                color: MevaCoinComponents.Style.blackTheme ? "#2a2a3e" : "#ffffff"
                border.color: confirmField.activeFocus
                    ? MevaCoinComponents.Style.orange
                    : (MevaCoinComponents.Style.blackTheme ? "#3a3a4e" : "#d0d0d0")
                border.width: confirmField.activeFocus ? 2 : 1
                visible: isSetup

                TextInput {
                    id: confirmField
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 16
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    color: MevaCoinComponents.Style.defaultFontColor
                    selectionColor: MevaCoinComponents.Style.orange
                    selectedTextColor: "#ffffff"
                    selectByMouse: true
                    echoMode: TextInput.Password
                    placeholderText: qsTr("Confirm password") + translationManager.emptyString
                }
            }

            MevaCoinComponents.TextPlain {
                id: errorText
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                color: MevaCoinComponents.Style.wookeyRed
                text: ""
                visible: text !== ""
            }

            MevaCoinComponents.StandardButton {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: isSetup
                    ? qsTr("Create access") + translationManager.emptyString
                    : qsTr("Enter") + translationManager.emptyString
                enabled: usernameField.text !== "" && passwordField.text !== ""
                onClicked: {
                    errorText.text = ""
                    if (isSetup) {
                        if (passwordField.text !== confirmField.text) {
                            errorText.text = qsTr("Passwords do not match") + translationManager.emptyString
                            return
                        }
                        if (passwordField.text.length < 4) {
                            errorText.text = qsTr("Password must be at least 4 characters") + translationManager.emptyString
                            return
                        }
                        persistentSettings.loginUsername = usernameField.text
                        persistentSettings.loginPassword = passwordField.text
                        root.loginSucceeded()
                    } else {
                        if (usernameField.text === persistentSettings.loginUsername && passwordField.text === persistentSettings.loginPassword) {
                            root.loginSucceeded()
                        } else {
                            errorText.text = qsTr("Invalid username or password") + translationManager.emptyString
                        }
                    }
                }
            }
        }
    }
}
