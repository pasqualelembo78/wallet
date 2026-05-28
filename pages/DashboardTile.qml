// Copyright (c) 2014-2024, The MevaCoin Project
// All rights reserved. BSD License — see LICENSE for details.

import QtQuick 2.9
import QtQuick.Layouts 1.1

import "../components" as MevaCoinComponents

// Tile riutilizzabile per le scorciatoie nel Dashboard
// Compatibile Qt 5.15 (inline component non disponibile in Qt 5)
Rectangle {
    property string iconText: "●"
    property string label: ""
    signal tileClicked()

    Layout.fillWidth: true
    height: 72
    radius: 12
    color: tileMouseArea.pressed
        ? (MevaCoinComponents.Style.blackTheme ? "#252525" : "#e0e0e0")
        : (MevaCoinComponents.Style.blackTheme ? "#1a1a1a" : "#f5f5f5")
    border.color: MevaCoinComponents.Style.blackTheme ? "#2a2a2a" : "#e0e0e0"
    border.width: 1

    Behavior on color { ColorAnimation { duration: 80 } }

    Column {
        anchors.centerIn: parent
        spacing: 4

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: iconText
            font.pixelSize: 22
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: label
            font.family: MevaCoinComponents.Style.fontRegular.name
            font.pixelSize: 12
            color: MevaCoinComponents.Style.defaultFontColor
        }
    }

    MouseArea {
        id: tileMouseArea
        anchors.fill: parent
        onClicked: tileClicked()
    }
}
