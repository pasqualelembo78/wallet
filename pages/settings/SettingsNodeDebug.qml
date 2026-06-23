import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import FontAwesome 1.0

import "../../components" as MevaCoinComponents
import mevacoinComponents.Network 1.0
import mevacoinComponents.Clipboard 1.0

Rectangle {
    id: root
    color: "transparent"
    Layout.fillWidth: true
    property int debugHeight: 800

    Clipboard { id: clipboard }

    // ── MODELLO LOG ──
    ListModel { id: logModel }

    // Connetti i segnali di logging live da MevatrustManager
    Connections {
        target: mevatrustManager
        function onRpcRequestSent(method, params, url) {
            logModel.append({
                timestamp: new Date().toLocaleString(),
                direction: "▶ REQ",
                server: url,
                details: method + (params !== "" && params !== "{}" ? " " + params : ""),
                response: ""
            });
            if (logModel.count > 500) logModel.remove(0, logModel.count - 500);
        }
        function onRpcResponseReceived(method, response, error, elapsedMs) {
            var detail = method + " (" + elapsedMs + "ms)";
            if (error !== "") detail += " ERR: " + error;
            logModel.append({
                timestamp: new Date().toLocaleString(),
                direction: error !== "" ? "◄ ERR" : "◄ RSP",
                server: "",
                details: detail,
                response: error !== "" ? error : response
            });
            if (logModel.count > 500) logModel.remove(0, logModel.count - 500);
        }
        function onErrorOccurred(msg) {
            logModel.append({
                timestamp: new Date().toLocaleString(),
                direction: "◄ ERR",
                server: "",
                details: msg,
                response: ""
            });
            if (logModel.count > 500) logModel.remove(0, logModel.count - 500);
        }
    }

    // ── MODELLO TEST SERVER ──
    ListModel { id: testModel }

    property bool testRunning: false

    Network {
        id: network
        proxyAddress: persistentSettings.getProxyAddress()
    }

    function clearLogs() { logModel.clear() }
    function clearTestResults() { testModel.clear() }

    function addLog(timestamp, direction, server, details, response) {
        logModel.append({
            timestamp: timestamp || new Date().toLocaleString(),
            direction: direction || "",
            server: server || "",
            details: details || "",
            response: response || ""
        });
        if (logModel.count > 500) logModel.remove(0, logModel.count - 500);
    }

    function testServer(host, port, idx) {
        var url = "http://" + host + ":" + port + "/get_info";
        var startTime = new Date().getTime();
        addLog(new Date().toLocaleString(), "► REQ", host + ":" + port, "GET /get_info", "");
        network.getJSON(url, function(resp, error) {
            var elapsed = new Date().getTime() - startTime;
            if (error) {
                var errMsg = "ERRORE: " + error + " (" + elapsed + "ms)";
                addLog(new Date().toLocaleString(), "◄ ERR", host + ":" + port, errMsg, "");
                if (idx >= 0 && idx < testModel.count) {
                    testModel.set(idx, {
                        server: host + ":" + port,
                        status: "⚠ offline",
                        height: "-",
                        version: "-",
                        latency: elapsed + "ms",
                        error: error,
                        online: false
                    });
                }
            } else {
                var info = resp ? resp : {};
                var height = info.height !== undefined ? info.height : "?";
                var version = info.version !== undefined ? info.version : "";
                var nettype = info.nettype !== undefined ? info.nettype : "";
                var isMainnet = nettype === "mainnet" || info.mainnet === true;
                var jsonStr = JSON.stringify(info, null, 2);
                var isMevaCoin = true; // accettiamo sempre, la versione RPC fa da filtro
                var extra = "";
                // Mostra la versione RPC (CORE_RPC_VERSION) se disponibile
                var rpcVersion = info.core_rpc_version !== undefined ? " RPCv" + info.core_rpc_version : "";
                addLog(new Date().toLocaleString(), "◄ RSP", host + ":" + port,
                    "OK (" + elapsed + "ms) height=" + height + rpcVersion, jsonStr);
                if (idx >= 0 && idx < testModel.count) {
                    testModel.set(idx, {
                        server: host + ":" + port,
                        status: "● online",
                        height: "" + height,
                        version: "" + version + (!isMainnet && version ? " (" + nettype + ")" : "") + rpcVersion,
                        latency: elapsed + "ms",
                        error: version ? "" : "Versione sconosciuta",
                        online: true
                    });
                }
            }
        });
    }

    function testSeedServers() {
        clearTestResults();
        testRunning = true;
        var servers = [
            { host: "82.165.218.56", port: "18081", name: "seed1" },
            { host: "87.106.40.193", port: "18081", name: "seed2" },
            { host: "87.106.233.72", port: "18081", name: "seed3" }
        ];
        for (var i = 0; i < servers.length; i++) {
            testModel.append({
                server: servers[i].host + ":" + servers[i].port,
                status: "⋯ testing",
                height: "-",
                version: "-",
                latency: "-",
                error: "",
                online: false
            });
        }
        for (var j = 0; j < servers.length; j++) {
            testServer(servers[j].host, servers[j].port, j);
        }
        Qt.callLater(function() { testRunning = false; });
    }

    function testRemoteNodes() {
        clearTestResults();
        testRunning = true;
        var count = remoteNodesModel.count;
        if (count === 0) { testRunning = false; return; }
        for (var i = 0; i < count; i++) {
            var node = remoteNodesModel.get(i);
            if (!node) continue;
            var parts = node.address.split(":");
            var host = parts[0];
            var port = parts.length > 1 ? parts[1] : "18081";
            testModel.append({
                server: node.address,
                status: "⋯ testing",
                height: "-",
                version: "-",
                latency: "-",
                error: "",
                online: false
            });
        }
        for (var j = 0; j < count; j++) {
            var node2 = remoteNodesModel.get(j);
            if (!node2) continue;
            var parts2 = node2.address.split(":");
            var host2 = parts2[0];
            var port2 = parts2.length > 1 ? parts2[1] : "18081";
            testServer(host2, port2, j);
        }
        Qt.callLater(function() { testRunning = false; });
    }

    function copyLogs() {
        var text = "";
        for (var i = 0; i < logModel.count; i++) {
            var entry = logModel.get(i);
            text += entry.timestamp + " | " + entry.direction + " | " + entry.server + " | " + entry.details + "\n";
            if (entry.response) {
                text += "    " + entry.response + "\n";
            }
        }
        clipboard.setText(text);
        appWindow.showStatusMessage("Log copiato negli appunti", 2);
    }

    ColumnLayout {
        anchors.margins: 20
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 12

        // ── INTESTAZIONE ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            MevaCoinComponents.TextPlain {
                font.bold: true
                font.pixelSize: 16
                color: MevaCoinComponents.Style.defaultFontColor
                text: qsTr("Monitor Connessioni API") + translationManager.emptyString
            }

            Item { Layout.fillWidth: true }

            MevaCoinComponents.StandardButton {
                small: true
                text: qsTr("Test Nodi Remoti") + translationManager.emptyString
                enabled: !testRunning && remoteNodesModel.count > 0
                onClicked: testRemoteNodes()
            }

            MevaCoinComponents.StandardButton {
                small: true
                text: qsTr("Test Seed Server") + translationManager.emptyString
                enabled: !testRunning
                onClicked: testSeedServers()
            }

            MevaCoinComponents.StandardButton {
                small: true
                text: qsTr("Copia Log") + translationManager.emptyString
                enabled: logModel.count > 0
                onClicked: copyLogs()
            }

            MevaCoinComponents.StandardButton {
                small: true
                text: qsTr("Pulisci Log") + translationManager.emptyString
                onClicked: clearLogs()
            }
        }

        // ── TABELLA TEST SERVER ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(220, testModel.count * 36 + 50)
            radius: 8
            color: MevaCoinComponents.Style.blackTheme ? "#1e1e1e" : "#f5f5f5"
            border.color: MevaCoinComponents.Style.dividerColor
            border.width: 1
            visible: testModel.count > 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                MevaCoinComponents.TextPlain {
                    font.bold: true
                    font.pixelSize: 13
                    color: MevaCoinComponents.Style.defaultFontColor
                    text: qsTr("Risultati Test Server") + translationManager.emptyString
                }

                ListView {
                    id: testListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: testModel
                    boundsBehavior: Flickable.StopAtBounds

                    header: Rectangle {
                        height: 28
                        color: MevaCoinComponents.Style.blackTheme ? "#2a2a2a" : "#e0e0e0"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            spacing: 4
                            MevaCoinComponents.TextPlain { font.bold: true; font.pixelSize: 11; color: MevaCoinComponents.Style.defaultFontColor; Layout.preferredWidth: 180; text: "Server" }
                            MevaCoinComponents.TextPlain { font.bold: true; font.pixelSize: 11; color: MevaCoinComponents.Style.defaultFontColor; Layout.preferredWidth: 80; text: "Stato" }
                            MevaCoinComponents.TextPlain { font.bold: true; font.pixelSize: 11; color: MevaCoinComponents.Style.defaultFontColor; Layout.preferredWidth: 70; text: "Altezza" }
                            MevaCoinComponents.TextPlain { font.bold: true; font.pixelSize: 11; color: MevaCoinComponents.Style.defaultFontColor; Layout.preferredWidth: 70; text: "Latenza" }
                            MevaCoinComponents.TextPlain { font.bold: true; font.pixelSize: 11; color: MevaCoinComponents.Style.defaultFontColor; Layout.fillWidth: true; text: "Versione" }
                            MevaCoinComponents.TextPlain { font.bold: true; font.pixelSize: 11; color: MevaCoinComponents.Style.defaultFontColor; Layout.preferredWidth: 160; text: "Errore / Note" }
                        }
                    }

                    delegate: Rectangle {
                        height: 28
                        color: index % 2 === 0 ? "transparent" : (MevaCoinComponents.Style.blackTheme ? "#252525" : "#fafafa")
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            spacing: 4
                            MevaCoinComponents.TextPlain { font.pixelSize: 11; font.family: "monospace"; color: MevaCoinComponents.Style.defaultFontColor; Layout.preferredWidth: 180; text: server; elide: Text.ElideRight }
                            MevaCoinComponents.TextPlain {
                                font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 80
                                color: online ? "#2EB358" : "#FF4444"
                                text: status
                            }
                            MevaCoinComponents.TextPlain { font.pixelSize: 11; font.family: "monospace"; color: MevaCoinComponents.Style.defaultFontColor; Layout.preferredWidth: 70; text: height }
                            MevaCoinComponents.TextPlain { font.pixelSize: 11; color: MevaCoinComponents.Style.defaultFontColor; Layout.preferredWidth: 70; text: latency }
                            MevaCoinComponents.TextPlain { font.pixelSize: 10; font.family: "monospace"; color: MevaCoinComponents.Style.defaultFontColor; Layout.fillWidth: true; text: version; elide: Text.ElideRight }
                            MevaCoinComponents.TextPlain { font.pixelSize: 10; color: online ? (error ? "#FFaa00" : MevaCoinComponents.Style.dimmedFontColor) : "#FF4444"; Layout.preferredWidth: 160; text: error; elide: Text.ElideRight }
                        }
                    }
                }
            }
        }

        // ── LOG CHIAMATE ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 350
            radius: 8
            color: MevaCoinComponents.Style.blackTheme ? "#1e1e1e" : "#f5f5f5"
            border.color: MevaCoinComponents.Style.dividerColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                MevaCoinComponents.TextPlain {
                    font.bold: true
                    font.pixelSize: 13
                    color: MevaCoinComponents.Style.defaultFontColor
                    text: qsTr("Log Chiamate (%1)").arg(logModel.count) + translationManager.emptyString
                }

                ListView {
                    id: logListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: logModel
                    boundsBehavior: Flickable.StopAtBounds
                    currentIndex: logModel.count - 1
                    onCountChanged: {
                        if (count > 0) currentIndex = count - 1;
                    }

                    delegate: Rectangle {
                        height: entryDetails.visible ? 62 : 28
                        color: index % 2 === 0 ? "transparent" : (MevaCoinComponents.Style.blackTheme ? "#252525" : "#fafafa")

                        property bool expanded: false

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            onClicked: parent.expanded = !parent.expanded
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Rectangle {
                                    width: 6; height: 6; radius: 3
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: direction === "◄ RSP" ? "#2EB358"
                                         : direction === "◄ ERR" ? "#FF4444"
                                         : direction === "► REQ" ? "#FFaa00"
                                         : direction === "status" ? "#888888" : "#888888"
                                }

                                MevaCoinComponents.TextPlain {
                                    font.pixelSize: 10
                                    font.family: "monospace"
                                    color: MevaCoinComponents.Style.dimmedFontColor
                                    text: timestamp
                                    Layout.preferredWidth: 130
                                }

                                MevaCoinComponents.TextPlain {
                                    font.pixelSize: 11
                                    font.family: "monospace"
                                    font.bold: true
                                    color: direction === "◄ RSP" ? "#2EB358"
                                         : direction === "◄ ERR" ? "#FF4444"
                                         : direction === "► REQ" ? "#FFaa00"
                                         : MevaCoinComponents.Style.defaultFontColor
                                    text: direction
                                    Layout.preferredWidth: 50
                                }

                                MevaCoinComponents.TextPlain {
                                    font.pixelSize: 11
                                    font.family: "monospace"
                                    color: MevaCoinComponents.Style.defaultFontColor
                                    text: server
                                    Layout.preferredWidth: 180
                                    elide: Text.ElideRight
                                }

                                MevaCoinComponents.TextPlain {
                                    font.pixelSize: 11
                                    color: MevaCoinComponents.Style.defaultFontColor
                                    text: details
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            MevaCoinComponents.TextPlain {
                                id: entryDetails
                                font.pixelSize: 10
                                font.family: "monospace"
                                color: MevaCoinComponents.Style.dimmedFontColor
                                text: response
                                Layout.fillWidth: true
                                visible: parent.parent.expanded && response !== ""
                                wrapMode: Text.Wrap
                                topPadding: 4
                                leftPadding: 16
                                maximumLineCount: 5
                                clip: true
                            }
                        }
                    }
                }
            }
        }

        // ── LEGENDA ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            MevaCoinComponents.TextPlain {
                font.pixelSize: 10
                color: MevaCoinComponents.Style.dimmedFontColor
                text: "● Verde = Connesso / Riuscito"
            }
            MevaCoinComponents.TextPlain {
                font.pixelSize: 10
                color: MevaCoinComponents.Style.dimmedFontColor
                text: "● Rosso = Errore / Disconnesso"
            }
            MevaCoinComponents.TextPlain {
                font.pixelSize: 10
                color: MevaCoinComponents.Style.dimmedFontColor
                text: "● Giallo = Richiesta in corso"
            }
            MevaCoinComponents.TextPlain {
                font.pixelSize: 10
                color: MevaCoinComponents.Style.dimmedFontColor
                text: "Clicca su una riga per espandere dettagli JSON"
            }
        }

        // ── INFORMAZIONI CONNESSIONE ATTUALE ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: infoCol.implicitHeight + 20
            radius: 8
            color: MevaCoinComponents.Style.blackTheme ? "#1e1e1e" : "#f5f5f5"
            border.color: MevaCoinComponents.Style.dividerColor
            border.width: 1

            ColumnLayout {
                id: infoCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                MevaCoinComponents.TextPlain {
                    font.bold: true
                    font.pixelSize: 13
                    color: MevaCoinComponents.Style.defaultFontColor
                    text: qsTr("Stato Connessione Attuale") + translationManager.emptyString
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 4

                    MevaCoinComponents.TextPlain { font.pixelSize: 11; color: MevaCoinComponents.Style.dimmedFontColor; text: "Server attivo:" }
                    MevaCoinComponents.TextPlain { font.pixelSize: 11; font.family: "monospace"; color: MevaCoinComponents.Style.defaultFontColor; text: appWindow.currentDaemonAddress || "-" }

                    MevaCoinComponents.TextPlain { font.pixelSize: 11; color: MevaCoinComponents.Style.dimmedFontColor; text: "Stato:" }
                    MevaCoinComponents.TextPlain {
                        font.pixelSize: 11; font.bold: true
                        color: appWindow.disconnected ? "#FF4444" : "#2EB358"
                        text: appWindow.disconnected ? "Disconnesso" : "Connesso"
                    }

                    MevaCoinComponents.TextPlain { font.pixelSize: 11; color: MevaCoinComponents.Style.dimmedFontColor; text: "Daemon synced:" }
                    MevaCoinComponents.TextPlain {
                        font.pixelSize: 11; font.bold: true
                        color: appWindow.daemonSynced ? "#2EB358" : "#FFaa00"
                        text: appWindow.daemonSynced ? "Sincronizzato" : "In sync..."
                    }

                    MevaCoinComponents.TextPlain { font.pixelSize: 11; color: MevaCoinComponents.Style.dimmedFontColor; text: "Nodo remoto:" }
                    MevaCoinComponents.TextPlain { font.pixelSize: 11; color: MevaCoinComponents.Style.defaultFontColor; text: persistentSettings.useRemoteNode ? "Sì" : "No" }

                    MevaCoinComponents.TextPlain { font.pixelSize: 11; color: MevaCoinComponents.Style.dimmedFontColor; text: "Tentativi auto-failover:" }
                    MevaCoinComponents.TextPlain { font.pixelSize: 11; color: MevaCoinComponents.Style.defaultFontColor; text: "" + appWindow.autoReconnectTotalTries }

                    MevaCoinComponents.TextPlain { font.pixelSize: 11; color: MevaCoinComponents.Style.dimmedFontColor; text: "Wallet mode:" }
                    MevaCoinComponents.TextPlain { font.pixelSize: 11; color: MevaCoinComponents.Style.defaultFontColor; text: appWindow.walletMode === 0 ? "Simple" : appWindow.walletMode === 1 ? "Simple (bootstrap)" : "Advanced" }
                }
            }
        }

        // ── DAEMON CONSOLE LOG ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 220
            radius: 8
            color: MevaCoinComponents.Style.blackTheme ? "#1e1e1e" : "#f5f5f5"
            border.color: MevaCoinComponents.Style.dividerColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true

                    MevaCoinComponents.TextPlain {
                        font.bold: true
                        font.pixelSize: 13
                        color: MevaCoinComponents.Style.defaultFontColor
                        text: qsTr("Log Demone") + translationManager.emptyString
                    }

                    Item { Layout.fillWidth: true }

                    MevaCoinComponents.TextPlain {
                        font.pixelSize: 10
                        color: persistentSettings.useRemoteNode ? MevaCoinComponents.Style.dimmedFontColor : MevaCoinComponents.Style.defaultFontColor
                        text: persistentSettings.useRemoteNode ? qsTr("(non disponibile in modalità remote node)") : ""
                    }

                    MevaCoinComponents.StandardButton {
                        small: true
                        text: "Pulisci"
                        onClicked: daemonLogArea.clear()
                    }
                }

                Flickable {
                    id: daemonLogFlickable
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    TextArea.flickable: TextArea {
                        id: daemonLogArea
                        readOnly: true
                        font.family: "monospace"
                        font.pixelSize: 11
                        color: MevaCoinComponents.Style.defaultFontColor
                        background: Rectangle {
                            color: MevaCoinComponents.Style.blackTheme ? "#0d0d0d" : "#ffffff"
                            radius: 4
                        }
                        wrapMode: TextEdit.Wrap
                        textFormat: TextEdit.RichText

                        function appendLog(msg) {
                            var color = MevaCoinComponents.Style.defaultFontColor;
                            if (msg.toLowerCase().indexOf('error') >= 0)
                                color = "#FF4444";
                            else if (msg.toLowerCase().indexOf('warning') >= 0)
                                color = "#fa6800";
                            var html = "<span style='color:" + color + ";'>" + msg + "</span><br>";
                            daemonLogArea.insert(daemonLogArea.length, html);
                            if (daemonLogArea.length > 50000)
                                daemonLogArea.remove(0, daemonLogArea.length - 40000);
                            daemonLogArea.cursorPosition = daemonLogArea.length;
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    Component.onCompleted: {
        if (typeof daemonManager !== "undefined")
            daemonManager.daemonConsoleUpdated.connect(daemonLogArea.appendLog);
    }
}
