// Copyright (c) 2014-2024, The MevaCoin Project
// All rights reserved. BSD License — see LICENSE for details.

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

import "../components" as MevaCoinComponents

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard.qml — Schermata iniziale dell'app (Qt 5.15 compatible)
//
// Mostra saldo, bottoni Send/Receive, scorciatoie e link legali
// richiesti da Google Play (Privacy Policy, About, Open Source).
// Navigazione via appWindow.mobileNavigate() già esistente nel main.qml.
// ─────────────────────────────────────────────────────────────────────────────

Rectangle {
    id: dashboardPage
    color: "transparent"

    // Altezza totale — usata da MiddlePanel per il contentHeight del Flickable
    property int dashboardHeight: mainCol.implicitHeight + 40

    // Aggiorna con URL reale dopo aver pubblicato su GitHub Pages
    readonly property string privacyPolicyUrl: "https://pasqualelembo78.github.io/wallet/privacy-policy.html"

    // ── Layout principale ────────────────────────────────────────────────────
    ColumnLayout {
        id: mainCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 16
        spacing: 20

        // ── Saldo ────────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 110
            radius: 14
            color: MevaCoinComponents.Style.blackTheme ? "#1a1a1a" : "#f0f0f0"
            border.color: MevaCoinComponents.Style.blackTheme ? "#2a2a2a" : "#e0e0e0"
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Total Balance") + translationManager.emptyString
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 13
                    color: MevaCoinComponents.Style.dimmedFontColor
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: (typeof leftPanel !== "undefined" ? leftPanel.balanceString : "0.000000000000") + " MVC"
                    font.family: MevaCoinComponents.Style.fontBold.name
                    font.pixelSize: 26
                    font.bold: true
                    color: MevaCoinComponents.Style.defaultFontColor
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: typeof leftPanel !== "undefined" &&
                             leftPanel.balanceFiatString !== "?.??" &&
                             leftPanel.balanceFiatString !== ""
                    text: "~ " + (typeof leftPanel !== "undefined" ? leftPanel.balanceFiatString : "")
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 13
                    color: MevaCoinComponents.Style.dimmedFontColor
                }
            }
        }

        // ── Banner connessione nodo (visibile solo se disconnesso o in sync) ──
        Rectangle {
            id: nodeWarningBanner
            Layout.fillWidth: true
            height: 46
            radius: 10
            visible: appWindow.disconnected || !appWindow.daemonSynced

            color: appWindow.disconnected
                ? (MevaCoinComponents.Style.blackTheme ? "#2a1a1a" : "#fff3f3")
                : (MevaCoinComponents.Style.blackTheme ? "#2a2200" : "#fffbe6")

            border.color: appWindow.disconnected ? "#FF4444" : "#FFaa00"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                Rectangle {
                    width: 9; height: 9; radius: 5
                    Layout.alignment: Qt.AlignVCenter
                    color: appWindow.disconnected ? "#FF4444" : "#FFaa00"
                }

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: appWindow.disconnected
                        ? qsTr("Wallet not connected to node. Tap to configure.") + translationManager.emptyString
                        : qsTr("Synchronizing with node...") + translationManager.emptyString
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 13
                    color: appWindow.disconnected
                        ? (MevaCoinComponents.Style.blackTheme ? "#FF8888" : "#cc0000")
                        : (MevaCoinComponents.Style.blackTheme ? "#FFcc44" : "#aa7700")
                    elide: Text.ElideRight
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: "›"
                    font.pixelSize: 22
                    font.bold: true
                    color: appWindow.disconnected ? "#FF4444" : "#FFaa00"
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    middlePanel.settingsView.settingsStateViewState = "Node";
                    appWindow.showPageRequest("Settings");
                }
            }
        }

        // ── Send / Receive ───────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                height: 56
                radius: 12
                color: sendMA.pressed ? "#d05500" : "#FF6C3C"
                Behavior on color { ColorAnimation { duration: 100 } }

                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Text { text: "\u2191"; font.pixelSize: 20; font.bold: true; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: qsTr("Send") + translationManager.emptyString
                        font.family: MevaCoinComponents.Style.fontBold.name
                        font.pixelSize: 16; font.bold: true; color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea { id: sendMA; anchors.fill: parent; onClicked: appWindow.mobileNavigate("Transfer") }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 56
                radius: 12
                color: receiveMA.pressed
                    ? (MevaCoinComponents.Style.blackTheme ? "#2a3a2a" : "#c8e6c9")
                    : (MevaCoinComponents.Style.blackTheme ? "#1a2a1a" : "#e8f5e9")
                border.color: "#2EB358"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }

                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Text { text: "\u2193"; font.pixelSize: 20; font.bold: true; color: "#2EB358"; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: qsTr("Receive") + translationManager.emptyString
                        font.family: MevaCoinComponents.Style.fontBold.name
                        font.pixelSize: 16; font.bold: true; color: "#2EB358"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea { id: receiveMA; anchors.fill: parent; onClicked: appWindow.mobileNavigate("Receive") }
            }
        }

        // ── Etichetta sezione ────────────────────────────────────────────────
        Text {
            Layout.fillWidth: true
            text: qsTr("Quick Access") + translationManager.emptyString
            font.family: MevaCoinComponents.Style.fontBold.name
            font.pixelSize: 13
            font.bold: true
            color: MevaCoinComponents.Style.dimmedFontColor
            topPadding: 4
        }

        // ── Griglia scorciatoie (DashboardTile è file separato) ──────────────
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 12
            rowSpacing: 12

            DashboardTile {
                iconText: "\u23F1"
                label: qsTr("History") + translationManager.emptyString
                onTileClicked: appWindow.mobileNavigate("History")
            }
            DashboardTile {
                iconText: "\uD83D\uDCD6"
                label: qsTr("Address Book") + translationManager.emptyString
                onTileClicked: appWindow.mobileNavigate("AddressBook")
            }
            DashboardTile {
                iconText: "\uD83D\uDC64"
                label: qsTr("Account") + translationManager.emptyString
                onTileClicked: appWindow.mobileNavigate("Account")
            }
            DashboardTile {
                iconText: "\u2699"
                label: qsTr("Settings") + translationManager.emptyString
                onTileClicked: appWindow.mobileNavigate("Settings")
            }
        }

        // ── Separatore ───────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: MevaCoinComponents.Style.dividerColor
            opacity: MevaCoinComponents.Style.dividerOpacity
        }

        // ── Link legali (richiesti da Google Play) ───────────────────────────
        Text {
            Layout.fillWidth: true
            text: qsTr("Legal") + translationManager.emptyString
            font.family: MevaCoinComponents.Style.fontBold.name
            font.pixelSize: 13
            font.bold: true
            color: MevaCoinComponents.Style.dimmedFontColor
        }

        // Privacy Policy
        Rectangle {
            Layout.fillWidth: true
            height: 48
            radius: 10
            color: ppMA.pressed
                ? (MevaCoinComponents.Style.blackTheme ? "#222222" : "#e8e8e8")
                : (MevaCoinComponents.Style.blackTheme ? "#1a1a1a" : "#f5f5f5")
            border.color: MevaCoinComponents.Style.blackTheme ? "#2a2a2a" : "#e0e0e0"
            border.width: 1
            Behavior on color { ColorAnimation { duration: 80 } }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text { text: "\uD83D\uDD12"; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: qsTr("Privacy Policy") + translationManager.emptyString
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 14
                    color: MevaCoinComponents.Style.defaultFontColor
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 60
                }
                Text { text: "\u203A"; font.pixelSize: 20; color: MevaCoinComponents.Style.dimmedFontColor; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea { id: ppMA; anchors.fill: parent; onClicked: Qt.openUrlExternally(dashboardPage.privacyPolicyUrl) }
        }

        // About MevaCoin
        Rectangle {
            Layout.fillWidth: true
            height: 48
            radius: 10
            color: aboutMA.pressed
                ? (MevaCoinComponents.Style.blackTheme ? "#222222" : "#e8e8e8")
                : (MevaCoinComponents.Style.blackTheme ? "#1a1a1a" : "#f5f5f5")
            border.color: MevaCoinComponents.Style.blackTheme ? "#2a2a2a" : "#e0e0e0"
            border.width: 1
            Behavior on color { ColorAnimation { duration: 80 } }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text { text: "\u2139"; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: qsTr("About MevaCoin") + translationManager.emptyString
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 14
                    color: MevaCoinComponents.Style.defaultFontColor
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 60
                }
                Text { text: "\u203A"; font.pixelSize: 20; color: MevaCoinComponents.Style.dimmedFontColor; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea { id: aboutMA; anchors.fill: parent; onClicked: Qt.openUrlExternally("https://mevacoin.com") }
        }

        // Open Source
        Rectangle {
            Layout.fillWidth: true
            height: 56
            radius: 10
            color: srcMA.pressed
                ? (MevaCoinComponents.Style.blackTheme ? "#222222" : "#e8e8e8")
                : (MevaCoinComponents.Style.blackTheme ? "#1a1a1a" : "#f5f5f5")
            border.color: MevaCoinComponents.Style.blackTheme ? "#2a2a2a" : "#e0e0e0"
            border.width: 1
            Behavior on color { ColorAnimation { duration: 80 } }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 52
                anchors.rightMargin: 32
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: qsTr("Open Source Code") + translationManager.emptyString
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 14
                    color: MevaCoinComponents.Style.defaultFontColor
                }
                Text {
                    text: "github.com/pasqualelembo78/wallet"
                    font.family: MevaCoinComponents.Style.fontRegular.name
                    font.pixelSize: 11
                    color: MevaCoinComponents.Style.dimmedFontColor
                }
            }

            Text { text: "\uD83D\uDCC2"; font.pixelSize: 18; anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter }
            Text { text: "\u203A"; font.pixelSize: 20; color: MevaCoinComponents.Style.dimmedFontColor; anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter }

            MouseArea { id: srcMA; anchors.fill: parent; onClicked: Qt.openUrlExternally("https://github.com/pasqualelembo78/wallet") }
        }

        // Spazio inferiore
        Item { Layout.fillWidth: true; height: 20 }
    }
}
