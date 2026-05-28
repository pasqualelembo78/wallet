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


import QtQml 2.0
import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import mevacoinComponents.Wallet 1.0

import "./pages"
import "./pages/settings"
import "./pages/merchant"
import "./components" as MevaCoinComponents
import "./components/effects/" as MevaCoinEffects

Rectangle {
    id: root
    color: MevaCoinComponents.Style.middlePanelBackgroundColor

    property Item currentView
    property Item previousView
    property int minHeight: (appWindow.height > 800) ? appWindow.height : 800
    property alias contentHeight: mainFlickable.contentHeight
    property alias flickable: mainFlickable

    property Transfer transferView: Transfer {
        onPaymentClicked: root.paymentClicked(recipients, paymentId, mixinCount, priority, description)
        onSweepUnmixableClicked: root.sweepUnmixableClicked()
    }
    property Receive receiveView: Receive { }
    property Merchant merchantView: Merchant { }
    property History historyView: History { }
    property Advanced advancedView: Advanced { }
    property Settings settingsView: Settings { }
    property AddressBook addressBookView: AddressBook { }
    property Keys keysView: Keys { }
    property Account accountView: Account { }
    property Dashboard dashboardView: Dashboard { }
    property Privacy privacyView: Privacy { }

    signal paymentClicked(var recipients, string paymentId, int mixinCount, int priority, string description)
    signal sweepUnmixableClicked()
    signal generatePaymentIdInvoked()
    signal getProofClicked(string txid, string address, string message, string amount);
    signal checkProofClicked(string txid, string address, string message, string signature);

    Rectangle {
        // grey background on merchantView
        visible: currentView === merchantView
        color: MevaCoinComponents.Style.mevacoinGrey
        anchors.fill: parent
    }

    MevaCoinEffects.GradientBackground {
        visible: currentView !== merchantView
        anchors.fill: parent
        fallBackColor: MevaCoinComponents.Style.middlePanelBackgroundColor
        initialStartColor: MevaCoinComponents.Style.middlePanelBackgroundGradientStart
        initialStopColor: MevaCoinComponents.Style.middlePanelBackgroundGradientStop
        blackColorStart: MevaCoinComponents.Style._b_middlePanelBackgroundGradientStart
        blackColorStop: MevaCoinComponents.Style._b_middlePanelBackgroundGradientStop
        whiteColorStart: MevaCoinComponents.Style._w_middlePanelBackgroundGradientStart
        whiteColorStop: MevaCoinComponents.Style._w_middlePanelBackgroundGradientStop
        start: Qt.point(0, 0)
        end: Qt.point(height, width)
    }

    onCurrentViewChanged: {
        if (previousView) {
            if (typeof previousView.onPageClosed === "function") {
                previousView.onPageClosed();
            }
        }
        previousView = currentView
        if (currentView) {
            stackView.replace(currentView)
            // Component.onCompleted is called before wallet is initilized
            if (typeof currentView.onPageCompleted === "function") {
                currentView.onPageCompleted();
            }
        }
    }

    function updateStatus(){
        transferView.updateStatus();
    }

    // send from AddressBook
    function sendTo(address, paymentId, description){
        root.state = "Transfer";
        transferView.sendTo(address, paymentId, description);
    }

    // open Transactions page with search term in search field
    function searchInHistory(searchTerm){
        root.state = "History";
        historyView.searchInHistory(searchTerm);
    }

        states: [
            State {
                name: "History"
                PropertyChanges { target: root; currentView: historyView }
                PropertyChanges { target: mainFlickable; contentHeight: historyView.contentHeight + 80}
            }, State {
                name: "Transfer"
                PropertyChanges { target: root; currentView: transferView }
                PropertyChanges { target: mainFlickable; contentHeight: transferView.transferHeight1 + transferView.transferHeight2 + 80 }
            }, State {
                name: "Receive"
                PropertyChanges { target: root; currentView: receiveView }
                PropertyChanges { target: mainFlickable; contentHeight: receiveView.receiveHeight + 80 }
            }, State {
                name: "Merchant"
                PropertyChanges { target: root; currentView: merchantView }
                PropertyChanges { target: mainFlickable; contentHeight: merchantView.merchantHeight + 80 }
            }, State {
                name: "AddressBook"
                PropertyChanges { target: root; currentView: addressBookView }
                PropertyChanges { target: mainFlickable; contentHeight: addressBookView.addressbookHeight + 80 }
            }, State {
                name: "Advanced"
                PropertyChanges { target: root; currentView: advancedView }
                PropertyChanges { target: mainFlickable; contentHeight: advancedView.panelHeight }
            }, State {
                name: "Settings"
                PropertyChanges { target: root; currentView: settingsView }
                PropertyChanges { target: mainFlickable; contentHeight: settingsView.settingsHeight }
            }, State {
                name: "Keys"
                PropertyChanges { target: root; currentView: keysView }
                PropertyChanges { target: mainFlickable; contentHeight: keysView.keysHeight + 80}
            }, State {
                name: "Account"
                PropertyChanges { target: root; currentView: accountView }
                PropertyChanges { target: mainFlickable; contentHeight: accountView.accountHeight + 80 }
            }, State {
                name: "Dashboard"
                PropertyChanges { target: root; currentView: dashboardView }
                PropertyChanges { target: mainFlickable; contentHeight: dashboardView.dashboardHeight }
            }, State {
                name: "Privacy"
                PropertyChanges { target: root; currentView: privacyView }
                PropertyChanges { target: mainFlickable; contentHeight: privacyView.privacyHeight }
            }
        ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: {
            if(currentView === merchantView || currentView === historyView)
                return 0;

            return 20;
        }

        anchors.topMargin: (appWindow.persistentSettings.customDecorations && !mobileMode) ? 50 : 0
        anchors.bottomMargin: 0
        spacing: 0

        // mobileMiddlePanelPatch
    Flickable {
            id: mainFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: isMac ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                parent: root
                anchors.left: parent.right
                anchors.leftMargin: -14 // 10 margin + 4 scrollbar width
                anchors.top: parent.top
                anchors.topMargin: persistentSettings.customDecorations ? 60 : 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: persistentSettings.customDecorations ? 15 : 10
                onActiveChanged: if (!active && !isMac) active = true
            }

            onFlickingChanged: {
                releaseFocus();
            }

            // Views container
            StackView {
                id: stackView
                initialItem: dashboardView
                anchors.fill:parent
                clip: true // otherwise animation will affect left panel

                delegate: StackViewDelegate {
                    // MevaCoin: smooth fade + gentle slide transition
                    pushTransition: StackViewTransition {
                        PropertyAnimation {
                            target: enterItem
                            property: "opacity"
                            from: 0.0
                            to: 1.0
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                        PropertyAnimation {
                            target: enterItem
                            property: "x"
                            from: 18
                            to: 0
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                        PropertyAnimation {
                            target: exitItem
                            property: "opacity"
                            from: 1.0
                            to: 0.0
                            duration: 160
                            easing.type: Easing.InCubic
                        }
                    }
                    popTransition: StackViewTransition {
                        PropertyAnimation {
                            target: enterItem
                            property: "opacity"
                            from: 0.0
                            to: 1.0
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                        PropertyAnimation {
                            target: exitItem
                            property: "opacity"
                            from: 1.0
                            to: 0.0
                            duration: 160
                            easing.type: Easing.InCubic
                        }
                    }
                }
            }

        }// flickable
    }

    // border
    Rectangle {
        id: borderLeft
        visible: middlePanel.state !== "Merchant"
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 1
        color: MevaCoinComponents.Style.appWindowBorderColor

        MevaCoinEffects.ColorTransition {
            targetObj: parent
            blackColor: MevaCoinComponents.Style._b_appWindowBorderColor
            whiteColor: MevaCoinComponents.Style._w_appWindowBorderColor
        }
    }

    // border shadow
    Image {
        source: "qrc:///images/middlePanelShadow.png"
        width: 12
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: borderLeft.right
    }
}
