
import QtQuick 2.9
import QtQuick.Layouts 1.1
import "../../components" as MevaCoinComponents

Rectangle {
    color: "transparent"
    Layout.fillWidth: true
    property alias poolPageHeight: root.implicitHeight

    ColumnLayout {
        id: root
        anchors.margins: 20
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 20

        MevaCoinComponents.Label {
            fontSize: 24
            text: qsTr("Network Info") + translationManager.emptyString
        }

        MevaCoinComponents.TextPlain {
            Layout.fillWidth: true
            font.pixelSize: 14
            color: MevaCoinComponents.Style.dimmedFontColor
            wrapMode: Text.Wrap
            text: qsTr("Use the Node settings tab to configure your remote node connection.")
                  + translationManager.emptyString
        }

        Item { implicitHeight: 20 }
    }
}
