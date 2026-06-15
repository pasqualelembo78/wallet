import QtQuick 2.9
import QtQuick.Layouts 1.1
import "../components" as MevaCoinComponents

Rectangle {
    id: root
    property string badgeName: ""
    property string badgeDescription: ""
    property string badgeColor: MevaCoinComponents.Style.wookeyGreen
    property bool isEarned: true
    property int earnedHeight: 0
    property string badgeProgress: ""

    width: 160
    height: 100
    radius: 6
    color: MevaCoinComponents.Style.titleBarBackgroundGradientStart
    border.color: Qt.rgba(1,1,1,0.08)
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4

        Rectangle {
            width: 20
            height: 20
            radius: 10
            color: badgeColor
            opacity: isEarned ? 1.0 : 0.4
        }

        MevaCoinComponents.Label {
            text: badgeName
            fontSize: 12
            fontBold: true
            opacity: isEarned ? 1.0 : 0.5
        }

        MevaCoinComponents.Label {
            text: badgeDescription
            fontSize: 10
            opacity: 0.5
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        MevaCoinComponents.Label {
            visible: !isEarned && badgeProgress.length > 0
            text: badgeProgress
            fontSize: 9
            opacity: 0.4
        }

        MevaCoinComponents.Label {
            visible: isEarned && earnedHeight > 0
            text: qsTr("Block") + translationManager.emptyString + " " + earnedHeight
            fontSize: 9
            opacity: 0.4
        }
    }
}
