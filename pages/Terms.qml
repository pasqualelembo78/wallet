// Copyright (c) 2014-2025, The MevaCoin Project
// All rights reserved. BSD License — see LICENSE for details.

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

import "../components" as MevaCoinComponents

Rectangle {
    id: termsPage
    color: "transparent"

    property int termsHeight: termsCol.implicitHeight + 80

    Flickable {
        anchors.fill: parent
        contentHeight: termsCol.implicitHeight + 80
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar { }

        ColumnLayout {
            id: termsCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            anchors.topMargin: 24
            spacing: 16

            Text {
                Layout.fillWidth: true
                text: qsTr("Terms of Service & Risk Disclaimer") + translationManager.emptyString
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 22
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Last updated: July 2026") + translationManager.emptyString
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 12
                color: MevaCoinComponents.Style.dimmedFontColor
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: MevaCoinComponents.Style.blackTheme ? "#444444" : "#cccccc"
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("1. Acceptance of Terms")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("By downloading, installing, or using the MevaCoin Wallet application (the 'App'), you agree to be bound by these Terms of Service. If you do not agree, do not use the App.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("2. Description of Service")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("The App is a non-custodial cryptocurrency wallet that allows you to manage your MevaCoin (MVC) funds. The App does not store, transmit, or have access to your private keys or funds. All transactions are broadcast to the MevaCoin network and are subject to network confirmations.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("3. No Custodianship")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("You are solely responsible for your wallet, seed phrase, private keys, and any funds associated with them. The App developers cannot recover your funds, reverse transactions, or access your account. Losing your seed phrase results in permanent loss of access to your funds.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("4. Risk Disclaimer")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("Cryptocurrency trading and mining carry significant financial risk. The value of MevaCoin (MVC) can fluctuate dramatically. Past performance does not guarantee future results.\n\n"
                        + "Mining functionality in this App sends commands to a remote trusted node. All mining computation is performed on the server, not on your device. "
                        + "Mining may not be profitable and depends on factors including network difficulty, electricity costs, and hardware efficiency.\n\n"
                        + "This App does not provide financial advice. You should consult with a qualified financial advisor before engaging in cryptocurrency transactions or mining.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("5. No Warranty")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("The App is provided 'as is' without warranty of any kind, either express or implied. The developers make no guarantees regarding the availability, reliability, or accuracy of the App. You use the App at your own risk.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("6. Limitation of Liability")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("To the fullest extent permitted by law, the App developers shall not be liable for any direct, indirect, incidental, special, consequential, or exemplary damages arising from your use of the App, including but not limited to loss of funds, loss of data, or business interruption.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("7. Open Source License")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("This App is open-source software released under the BSD 3-Clause License. You may view, modify, and distribute the source code in accordance with the license terms. The source code is available at github.com/pasqualelembo78/wallet.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("8. Changes to These Terms")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("We reserve the right to modify these Terms at any time. Continued use of the App after changes constitutes acceptance of the new Terms.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("9. Contact")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("For questions about these Terms, please open an issue on our GitHub repository: https://github.com/pasqualelembo78/wallet")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            Item { Layout.preferredHeight: 40 }
        }
    }
}
