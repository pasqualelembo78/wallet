// Copyright (c) 2020-2024, The MevaCoin Project
// (license header identica all'originale)

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import mevacoinComponents.Downloader 1.0
import "../components" as MevaCoinComponents

Popup {
    id: updateDialog
    property bool active: false
    property bool allowed: true
    property string error: ""
    property string filename: ""
    property string hash: ""
    property double progress: url && downloader.total > 0 ? downloader.loaded * 100 / downloader.total : 0
    property string url: ""
    property bool valid: false
    property string version: ""

    background: Rectangle {
        border.color: MevaCoinComponents.Style.appWindowBorderColor
        border.width: 1
        color: MevaCoinComponents.Style.middlePanelBackgroundColor
    }
    closePolicy: Popup.NoAutoClose
    padding: 20
    visible: active && allowed

    function show(version, url, hash) {
        updateDialog.error = "";
        updateDialog.hash = hash;
        updateDialog.url = url;
        updateDialog.valid = false;
        updateDialog.version = version;
        updateDialog.active = true;
    }

    ColumnLayout {
        id: mainLayout
        spacing: updateDialog.padding

        Text {
            color: MevaCoinComponents.Style.defaultFontColor
            font.bold: true
            font.family: MevaCoinComponents.Style.fontRegular.name
            font.pixelSize: 18
            text: qsTr("New MevaCoin version v%1 is available.").arg(updateDialog.version)
        }

        Text {
            id: errorText
            color: "red"
            font.family: MevaCoinComponents.Style.fontRegular.name
            font.pixelSize: 18
            text: updateDialog.error
            visible: text
        }

        Text {
            id: statusText
            color: updateDialog.valid ? MevaCoinComponents.Style.green : MevaCoinComponents.Style.defaultFontColor
            font.family: MevaCoinComponents.Style.fontRegular.name
            font.pixelSize: 18
            visible: !errorText.visible
            text: {
                if (!updateDialog.url) return qsTr("Please visit mevacoin.com for details") + translationManager.emptyString;
                if (downloader.active) return "%1 (%2%)".arg(qsTr("Downloading")).arg(updateDialog.progress.toFixed(1)) + translationManager.emptyString;
                if (updateDialog.valid) return qsTr("Update downloaded, signature verified") + translationManager.emptyString;
                return qsTr("Do you want to download and verify new version?") + translationManager.emptyString;
            }
        }

        Rectangle {
            id: progressBar
            color: MevaCoinComponents.Style.lightGreyFontColor
            height: 3
            Layout.fillWidth: true
            visible: updateDialog.valid || downloader.active
            Rectangle {
                color: MevaCoinComponents.Style.buttonBackgroundColor
                height: parent.height
                width: parent.width * updateDialog.progress / 100
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: parent.spacing

            MevaCoinComponents.StandardButton {
                id: cancelButton
                fontBold: false
                primary: !updateDialog.url
                text: {
                    if (!updateDialog.url) return qsTr("Ok") + translationManager.emptyString;
                    if (updateDialog.valid || downloader.active || errorText.visible) return qsTr("Cancel") + translationManager.emptyString;
                    return qsTr("Download later") + translationManager.emptyString;
                }
                onClicked: { downloader.cancel(); updateDialog.active = false; }
            }

            MevaCoinComponents.StandardButton {
                id: downloadButton
                KeyNavigation.tab: cancelButton
                fontBold: false
                text: (updateDialog.error ? qsTr("Retry") : qsTr("Download")) + translationManager.emptyString
                visible: updateDialog.url && !updateDialog.valid && !downloader.active
                onClicked: {
                    updateDialog.error = "";
                    updateDialog.filename = updateDialog.url.replace(/^.*\//, '');
                    const downloadingStarted = downloader.get(updateDialog.url, updateDialog.hash, function(error) {
                        if (error) { console.error("Download failed", error); updateDialog.error = qsTr("Download failed") + translationManager.emptyString; }
                        else { updateDialog.valid = true; }
                    });
                    if (!downloadingStarted) updateDialog.error = qsTr("Failed to start download") + translationManager.emptyString;
                }
            }

            MevaCoinComponents.StandardButton {
                id: saveButton
                KeyNavigation.tab: cancelButton
                fontBold: false
                text: qsTr("Save to file") + translationManager.emptyString
                visible: updateDialog.valid
                onClicked: {
                    // Android: salva direttamente in Downloads (MediaStore, nessun dialog esterno)
                    if (Qt.platform.os === "android") {
                        const ok = downloader.saveToPublicDownloads(
                            updateDialog.filename,
                            "application/vnd.android.package-archive"
                        );
                        if (ok) {
                            cancelButton.clicked();
                            appWindow.showStatusMessage(qsTr("File saved to Downloads folder") + translationManager.emptyString, 5);
                        } else {
                            updateDialog.error = qsTr("Save operation failed") + translationManager.emptyString;
                        }
                        return;
                    }
                    // Desktop: comportamento originale
                    const fullPath = oshelper.openSaveFileDialog(
                        qsTr("Save as") + translationManager.emptyString,
                        oshelper.downloadLocation(),
                        updateDialog.filename);
                    if (!fullPath) return;
                    if (downloader.saveToFile(fullPath)) {
                        cancelButton.clicked();
                        oshelper.openContainingFolder(fullPath);
                    } else {
                        updateDialog.error = qsTr("Save operation failed") + translationManager.emptyString;
                    }
                }
            }
        }
    }

    Downloader {
        id: downloader
        proxyAddress: persistentSettings.getProxyAddress()
    }
}
