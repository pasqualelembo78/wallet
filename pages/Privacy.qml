// Copyright (c) 2014-2024, The MevaCoin Project
// All rights reserved. BSD License — see LICENSE for details.

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

import "../components" as MevaCoinComponents

// ─────────────────────────────────────────────────────────────────────────────
// Privacy.qml — Pagina Informativa sulla Privacy
// Accessibile dal menu in alto a destra → "Privacy"
// ─────────────────────────────────────────────────────────────────────────────

Rectangle {
    id: privacyPage
    color: "transparent"

    property int privacyHeight: privacyCol.implicitHeight + 80

    Flickable {
        anchors.fill: parent
        contentHeight: privacyCol.implicitHeight + 80
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar { }

        ColumnLayout {
            id: privacyCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            anchors.topMargin: 24
            spacing: 16

            // ── Titolo principale ─────────────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text: qsTr("Privacy Policy") + translationManager.emptyString
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 22
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Last updated: May 2025") + translationManager.emptyString
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 12
                color: MevaCoinComponents.Style.dimmedFontColor
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: MevaCoinComponents.Style.blackTheme ? "#444444" : "#cccccc"
            }

            // ── 1. Introduzione ───────────────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text: qsTr("1. Introduction")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("MevaCoin Wallet is an open-source, non-custodial cryptocurrency wallet. We respect your privacy and are committed to protecting any information related to your use of the app. This Privacy Policy explains what data we collect, why, and how we use it.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            // ── 2. Dati raccolti ──────────────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text: qsTr("2. Data We Collect")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("MevaCoin Wallet does NOT collect, store or transmit any personally identifiable information (PII) such as your name, email address, or government-issued ID.\n\nThe app communicates with MevaCoin network nodes only to:\n  • Synchronize your wallet balance and transaction history.\n  • Broadcast transactions you create.\n  • Retrieve blockchain data required for wallet operation.\n\nThese communications contain only cryptographic data inherent to the MevaCoin protocol and do not include any personal data.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            // ── 3. Dati locali ────────────────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text: qsTr("3. Data Stored Locally")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("All wallet data (keys, transaction records, settings) is stored exclusively on your device. We have no access to this data. You are solely responsible for backing up your seed phrase and keeping your device secure.\n\nLosing your seed phrase means permanent loss of access to your funds.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            // ── 4. Permessi ───────────────────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text: qsTr("4. App Permissions")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("The app may request the following device permissions:\n  • Internet access — required to connect to MevaCoin network nodes.\n  • Camera — used only for QR code scanning (optional).\n  • Storage — used only to read/write wallet files on your device.\n\nNo permission is used to collect personal data or track your activity.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            // ── 5. Terze parti ────────────────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text: qsTr("5. Third Parties")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("MevaCoin Wallet does not integrate third-party analytics SDKs, advertising networks, or social media trackers.\n\nIf you choose to use a remote node operated by a third party, that node operator may be able to see your IP address and the queries your wallet makes. We recommend using a trusted or self-operated node for maximum privacy.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            // ── 6. Sicurezza ──────────────────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text: qsTr("6. Security")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("We implement industry-standard cryptographic practices to protect your funds. However, no software is 100% immune to vulnerabilities. Please keep the app updated and protect your device with a strong passcode. Never share your seed phrase or private keys with anyone.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            // ── 7. Modifiche ──────────────────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text: qsTr("7. Changes to This Policy")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("We may update this Privacy Policy from time to time. When we do, we will update the date at the top of this page. Continued use of the app after changes constitutes acceptance of the updated policy.")
                font.family: MevaCoinComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MevaCoinComponents.Style.dimmedFontColor
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            // ── 8. Contatti ───────────────────────────────────────────────────
            Text {
                Layout.fillWidth: true
                text: qsTr("8. Contact Us")
                font.family: MevaCoinComponents.Style.fontBold.name
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("If you have questions about this Privacy Policy, please open an issue on our GitHub repository: https://github.com/pasqualelembo78/wallet")
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
