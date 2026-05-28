// Copyright (c) 2021-2024, The MevaCoin Project
// All rights reserved. (BSD 3-Clause License)

import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls 2.15 as QC2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import "../components" as MevaCoinComponents
import "."

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 900
    spacing: 0

    property int panelHeight: 900
    property alias signView: stateView.signView
    property alias prooveView: stateView.prooveView
    property alias documentHashView: stateView.documentHashView
    property alias state: stateView.state

    property int navCurrentIndex: 0
    property int navPreviousIndex: 0

    function stateToIndex(s) {
        if (s === "Prove")        return 0
        if (s === "SharedRingDB") return 1
        if (s === "Sign")         return 2
        if (s === "DocumentHash") return 3
        return 0
    }

    function currentSectionLabel() {
        if (stateView.state === "Prove")        return qsTr("Prove/check")
        if (stateView.state === "SharedRingDB") return qsTr("Shared RingDB")
        if (stateView.state === "Sign")         return qsTr("Sign/verify")
        if (stateView.state === "DocumentHash") return qsTr("Document Hash")
        return qsTr("Advanced")
    }

    // ── Header: section title + hamburger button ─────────────────────────────
    Rectangle {
        Layout.fillWidth: true
        height: 50
        color: "transparent"

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: MevaCoinComponents.Style.blackTheme ? "#555" : "#cccccc"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 4
            spacing: 0

            MevaCoinComponents.TextPlain {
                text: root.currentSectionLabel()
                font.pixelSize: 15
                font.bold: true
                color: MevaCoinComponents.Style.defaultFontColor
                Layout.fillWidth: true
            }

            // ── Hamburger button ─────────────────────────────────────────────
            Rectangle {
                id: hamburgerBtn
                width: 48
                height: 48
                radius: 4
                color: hamburgerMa.pressed
                       ? Qt.rgba(0.5, 0.5, 0.5, 0.2)
                       : "transparent"

                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 20; height: 2; radius: 1
                            color: MevaCoinComponents.Style.defaultFontColor
                        }
                    }
                }

                MouseArea {
                    id: hamburgerMa
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: navMenu.open()
                }

                // ── QC2 Popup: floats ABOVE all page content ─────────────────
                QC2.Popup {
                    id: navMenu

                    // Anchored to the hamburger button
                    x: hamburgerBtn.width - width
                    y: hamburgerBtn.height + 4

                    width: 220
                    height: menuColumn.implicitHeight + 8
                    padding: 0

                    // Close when tapping outside
                    closePolicy: QC2.Popup.CloseOnEscape | QC2.Popup.CloseOnPressOutside

                    // Semi-transparent background with rounded corners
                    background: Rectangle {
                        color: MevaCoinComponents.Style.blackTheme
                               ? Qt.rgba(0.10, 0.10, 0.10, 0.95)
                               : Qt.rgba(0.97, 0.97, 0.97, 0.97)
                        radius: 8
                        border.color: MevaCoinComponents.Style.blackTheme
                                      ? "#606060"
                                      : "#c0c0c0"
                        border.width: 1
                    }

                    Column {
                        id: menuColumn
                        width: 220
                        topPadding: 4
                        bottomPadding: 4

                        Repeater {
                            model: [
                                {label: qsTr("Prove/check"),   st: "Prove"},
                                {label: qsTr("Shared RingDB"), st: "SharedRingDB"},
                                {label: qsTr("Sign/verify"),   st: "Sign"},
                                {label: qsTr("Document Hash"), st: "DocumentHash"}
                            ]

                            delegate: Rectangle {
                                width: 220
                                height: 48
                                radius: 4
                                color: itemMa.containsMouse
                                       ? Qt.rgba(0.5, 0.5, 0.5, 0.15)
                                       : "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 14
                                    spacing: 0

                                    MevaCoinComponents.TextPlain {
                                        text: modelData.label
                                        font.pixelSize: 15
                                        font.bold: stateView.state === modelData.st
                                        color: stateView.state === modelData.st
                                               ? "#c89830"   // gold accent
                                               : MevaCoinComponents.Style.defaultFontColor
                                        Layout.fillWidth: true
                                    }

                                    // Checkmark for active item
                                    MevaCoinComponents.TextPlain {
                                        visible: stateView.state === modelData.st
                                        text: "✓"
                                        font.pixelSize: 15
                                        font.bold: true
                                        color: "#c89830"
                                    }
                                }

                                MouseArea {
                                    id: itemMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.navPreviousIndex = root.navCurrentIndex
                                        root.navCurrentIndex  = root.stateToIndex(modelData.st)
                                        stateView.state = modelData.st
                                        navMenu.close()
                                    }
                                }
                            }
                        }
                    }
                }
                // ── End Popup ────────────────────────────────────────────────
            }
        }
    }

    // ── Content area ─────────────────────────────────────────────────────────
    Rectangle {
        id: stateView
        property Item currentView
        property Item previousView
        property TxKey prooveView: TxKey { }
        property SharedRingDB sharedRingDBView: SharedRingDB { }
        property Sign signView: Sign { }
        property DocumentHash documentHashView: DocumentHash { }
        Layout.fillWidth: true
        Layout.preferredHeight: panelHeight
        color: "transparent"
        state: "Prove"

        onCurrentViewChanged: {
            if (previousView) {
                if (typeof previousView.onPageClosed === "function")
                    previousView.onPageClosed()
            }
            previousView = currentView
            if (currentView) {
                stackView.replace(currentView)
                if (typeof currentView.onPageCompleted === "function")
                    currentView.onPageCompleted()
            }
        }

        states: [
            State {
                name: "Prove"
                PropertyChanges { target: stateView; currentView: stateView.prooveView }
                PropertyChanges { target: root; panelHeight: stateView.prooveView.txkeyHeight + 140 }
            },
            State {
                name: "SharedRingDB"
                PropertyChanges { target: stateView; currentView: stateView.sharedRingDBView }
                PropertyChanges { target: root; panelHeight: stateView.sharedRingDBView.panelHeight + 140 }
            },
            State {
                name: "Sign"
                PropertyChanges { target: stateView; currentView: stateView.signView }
                PropertyChanges { target: root; panelHeight: stateView.signView.signHeight + 140 }
            },
            State {
                name: "DocumentHash"
                PropertyChanges { target: stateView; currentView: stateView.documentHashView }
                PropertyChanges { target: root; panelHeight: stateView.documentHashView.documentHashHeight + 140 }
            }
        ]

        StackView {
            id: stackView
            initialItem: stateView.prooveView
            anchors.fill: parent
            clip: false
            delegate: StackViewDelegate {
                pushTransition: StackViewTransition {
                    PropertyAnimation {
                        target: enterItem; property: "x"
                        from: (root.navCurrentIndex < root.navPreviousIndex ? 1 : -1) * -target.width
                        to: 0; duration: 250; easing.type: Easing.OutCubic
                    }
                    PropertyAnimation {
                        target: exitItem; property: "x"
                        from: 0
                        to: (root.navCurrentIndex < root.navPreviousIndex ? 1 : -1) * target.width
                        duration: 250; easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    function clearFields() {
        signView.clearFields()
        prooveView.clearFields()
    }
}
