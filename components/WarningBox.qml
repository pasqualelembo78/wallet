import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

import "." as MevaCoinComponents

Rectangle {
    id: root
    property alias text: content.text
    property alias textColor: content.color
    property int fontSize: 15
    property bool clickable: false       // set true to make the whole box tappable
    property string clickTooltip: ""     // optional "→ Configure node" label

    signal linkActivated
    signal clicked

    Layout.fillWidth: true
    Layout.preferredHeight: warningLayout.height

    color: MevaCoinComponents.Style.titleBarButtonHoverColor
    radius: 4
    border.color: clickable && tapArea.containsMouse
        ? MevaCoinComponents.Style.buttonBackgroundColor
        : MevaCoinComponents.Style.inputBorderColorInActive
    border.width: 1

    // Tappable overlay — only active when clickable is true
    MouseArea {
        id: tapArea
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    RowLayout {
        id: warningLayout
        spacing: 0
        anchors.left: parent.left
        anchors.right: parent.right

        Image {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: 33
            Layout.preferredWidth: 33
            Layout.rightMargin: 12
            Layout.leftMargin: 18
            Layout.topMargin: 12
            Layout.bottomMargin: 12
            source: "qrc:///images/warning.png"
        }

        Text {
            id: content
            Layout.fillWidth: true
            color: MevaCoinComponents.Style.defaultFontColor
            font.family: MevaCoinComponents.Style.fontRegular.name
            font.pixelSize: root.fontSize
            horizontalAlignment: TextInput.AlignLeft
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            leftPadding: 4
            rightPadding: root.clickable ? 4 : 18
            topPadding: 10
            bottomPadding: 10
            onLinkActivated: root.linkActivated()

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }

        // Arrow hint shown only when clickable
        Text {
            visible: root.clickable
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 14
            text: root.clickTooltip !== "" ? root.clickTooltip : "›"
            font.family: MevaCoinComponents.Style.fontMedium.name
            font.pixelSize: root.clickTooltip !== "" ? 12 : 20
            color: tapArea.containsMouse
                ? MevaCoinComponents.Style.buttonBackgroundColor
                : MevaCoinComponents.Style.dimmedFontColor
            opacity: 0.85
        }
    }
}
