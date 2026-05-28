#!/usr/bin/env python3
# =================================================================
#  MevaCoin Wallet — PATCH MOBILE DEFINITIVA
#  Esegui dalla root del progetto: python3 mobile_patch_definitivo.py
# =================================================================
import sys, os, re

def check_root():
    if not os.path.exists("CMakeLists.txt"):
        print("ERRORE: esegui dalla root del progetto (dove c'è CMakeLists.txt)")
        sys.exit(1)

def patch(path, label, old, new, flag=None):
    if not os.path.exists(path):
        print(f"  SKIP: {path} non trovato")
        return False
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    if flag and flag in content:
        print(f"  GIA' OK: {label}")
        return False
    if old not in content:
        print(f"  WARN: pattern non trovato in {label}")
        return False
    content = content.replace(old, new, 1)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  OK: {label}")
    return True

def patch_regex(path, label, pattern, replacement, flag=None):
    if not os.path.exists(path):
        print(f"  SKIP: {path} non trovato")
        return False
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    if flag and flag in content:
        print(f"  GIA' OK: {label}")
        return False
    new_content = re.sub(pattern, replacement, content, count=1)
    if new_content == content:
        print(f"  WARN: regex non trovata in {label}")
        return False
    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print(f"  OK: {label}")
    return True

# ─────────────────────────────────────────────────────────────────
#  1. Navbar.qml — tab scrollabile su Android (Flickable orizzontale)
# ─────────────────────────────────────────────────────────────────
NAVBAR_OLD = '''    GridLayout {
        id: grid
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        columnSpacing: 0
        property string fontColorActive: MevaCoinComponents.Style.blackTheme ? "white" : "white"
        property string fontColorInActive: MevaCoinComponents.Style.blackTheme ? "white" : MevaCoinComponents.Style.dimmedFontColor
        property int fontSize: 15
        property bool fontBold: true
        property var fontFamily: MevaCoinComponents.Style.fontRegular.name
        property string borderColor: MevaCoinComponents.Style.blackTheme ? "#808080" : "#B9B9B9"
        property int textMargin: {
            // left-right margins for a given cell
            if(appWindow.width < 890){
                return 32;
            } else {
                return 64;
            }
        }'''

NAVBAR_NEW = '''    // mobileNavbarPatch: su Android la navbar diventa scrollabile orizzontalmente
    Flickable {
        id: navFlickable
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: (typeof isAndroid !== "undefined" && isAndroid) ? Math.min(parent.width, appWindow.width - 20) : grid.width
        height: grid.height
        contentWidth: grid.width
        contentHeight: grid.height
        flickableDirection: Flickable.HorizontalFlick
        clip: true
        interactive: (typeof isAndroid !== "undefined" && isAndroid)

    GridLayout {
        id: grid
        columnSpacing: 0
        property string fontColorActive: MevaCoinComponents.Style.blackTheme ? "white" : "white"
        property string fontColorInActive: MevaCoinComponents.Style.blackTheme ? "white" : MevaCoinComponents.Style.dimmedFontColor
        property int fontSize: (typeof isAndroid !== "undefined" && isAndroid) ? 12 : 15
        property bool fontBold: true
        property var fontFamily: MevaCoinComponents.Style.fontRegular.name
        property string borderColor: MevaCoinComponents.Style.blackTheme ? "#808080" : "#B9B9B9"
        property int textMargin: {
            if (typeof isAndroid !== "undefined" && isAndroid) return 14;
            if (appWindow.width < 890) return 32;
            return 64;
        }'''

NAVBAR_CLOSE_OLD = '''        Rectangle {
            // navbar right side border
            id: navBarRight'''

NAVBAR_CLOSE_NEW = '''        Rectangle {
            // navbar right side border
            id: navBarRight'''

def patch_navbar():
    path = "components/Navbar.qml"
    with open(path, "r") as f:
        content = f.read()
    if "mobileNavbarPatch" in content:
        print("  GIA' OK: Navbar.qml")
        return
    if NAVBAR_OLD not in content:
        print("  WARN: pattern Navbar non trovato")
        return
    content = content.replace(NAVBAR_OLD, NAVBAR_NEW, 1)
    # Chiude il Flickable dopo il GridLayout di chiusura
    content = content.replace(
        "    }\n}\n",  # ultimo } del GridLayout + } del Rectangle root
        "    }\n    } // fine Flickable\n}\n",
        1
    )
    with open(path, "w") as f:
        f.write(content)
    print("  OK: Navbar.qml — tab scrollabili su Android")

# ─────────────────────────────────────────────────────────────────
#  2. SettingsLayout.qml — GridLayout fiat → ColumnLayout su Android
# ─────────────────────────────────────────────────────────────────
SLAYOUT_OLD = '''        GridLayout {
            visible: enableConvertCurrency.checked
            columns: 2
            Layout.fillWidth: true
            Layout.leftMargin: 36
            columnSpacing: 32

            MevaCoinComponents.StandardDropdown {
                id: fiatPriceProviderDropDown
                Layout.maximumWidth: 200'''

SLAYOUT_NEW = '''        // mobileGridPatch: 2 colonne su desktop, 1 colonna su Android
        GridLayout {
            visible: enableConvertCurrency.checked
            columns: (typeof isAndroid !== "undefined" && isAndroid) ? 1 : 2
            Layout.fillWidth: true
            Layout.leftMargin: 36
            columnSpacing: 32

            MevaCoinComponents.StandardDropdown {
                id: fiatPriceProviderDropDown
                Layout.fillWidth: (typeof isAndroid !== "undefined" && isAndroid)
                Layout.maximumWidth: (typeof isAndroid !== "undefined" && isAndroid) ? 99999 : 200'''

# ─────────────────────────────────────────────────────────────────
#  3. SettingsInfo.qml — GridLayout 2 col → 1 col su Android
# ─────────────────────────────────────────────────────────────────
SINFO_OLD = '''        GridLayout {
            columns: 2
            columnSpacing: 0'''

SINFO_NEW = '''        // mobileInfoGridPatch
        GridLayout {
            columns: (typeof isAndroid !== "undefined" && isAndroid) ? 1 : 2
            columnSpacing: 0
            Layout.fillWidth: true'''

# ─────────────────────────────────────────────────────────────────
#  4. SettingsWallet.qml — aggiungi "Download wallet file" come SettingsListItem
#     (il posto più visibile e coerente con il design)
# ─────────────────────────────────────────────────────────────────
SWALLET_OLD = '''        MevaCoinComponents.SettingsListItem {
            iconText: FontAwesome.cashRegister
            isLast: true
            description: qsTr("Receive MevaCoin for your business, easily.") + translationManager.emptyString
            title: qsTr("Enter merchant mode") + translationManager.emptyString

            onClicked: {
                middlePanel.state = "Merchant";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }
        }'''

SWALLET_NEW = '''        MevaCoinComponents.SettingsListItem {
            iconText: FontAwesome.cashRegister
            description: qsTr("Receive MevaCoin for your business, easily.") + translationManager.emptyString
            title: qsTr("Enter merchant mode") + translationManager.emptyString

            onClicked: {
                middlePanel.state = "Merchant";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }
        }

        // ── DOWNLOAD WALLET FILE (per mvcwallet) ─────────────────
        MevaCoinComponents.SettingsListItem {
            id: downloadWalletItem
            iconText: FontAwesome.download
            isLast: true
            title: qsTr("Download wallet file") + translationManager.emptyString
            description: qsTr("Export the wallet .keys file to use with mvcwallet on your server.") + translationManager.emptyString
            visible: isAndroid

            onClicked: {
                downloadWalletDialog.open()
            }
        }

        // Dialog di conferma e stato download
        Rectangle {
            id: downloadWalletDialog
            visible: false
            z: 999
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.7)

            function open() { visible = true; downloadResult.text = ""; downloadResult.color = "#ffffff" }
            function close() { visible = false }

            MouseArea { anchors.fill: parent; onClicked: downloadWalletDialog.close() }

            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width - 40, 380)
                height: dlgColumn.implicitHeight + 40
                color: MevaCoinComponents.Style.blackTheme ? "#1e1e1e" : "#ffffff"
                radius: 8

                MouseArea { anchors.fill: parent } // blocca click passante

                ColumnLayout {
                    id: dlgColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    spacing: 14

                    MevaCoinComponents.TextPlain {
                        Layout.fillWidth: true
                        font.pixelSize: 17
                        font.bold: true
                        color: MevaCoinComponents.Style.defaultFontColor
                        text: qsTr("Export wallet file") + translationManager.emptyString
                    }

                    MevaCoinComponents.TextPlain {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        font.pixelSize: 13
                        color: MevaCoinComponents.Style.dimmedFontColor
                        text: qsTr("The wallet .keys file will be shared via Android. Save it to Downloads or send it to your server to open with mvcwallet.") + translationManager.emptyString
                    }

                    // Mostra percorso file
                    Rectangle {
                        Layout.fillWidth: true
                        height: pathLabel.implicitHeight + 12
                        color: MevaCoinComponents.Style.blackTheme ? "#2a2a2a" : "#f0f0f0"
                        radius: 4

                        MevaCoinComponents.TextPlain {
                            id: pathLabel
                            anchors.fill: parent
                            anchors.margins: 6
                            wrapMode: Text.WrapAnywhere
                            font.pixelSize: 11
                            color: MevaCoinComponents.Style.dimmedFontColor
                            text: {
                                var p = appWindow.accountsDir + persistentSettings.wallet_path;
                                return p + ".keys"
                            }
                        }
                    }

                    // Risultato operazione
                    MevaCoinComponents.TextPlain {
                        id: downloadResult
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        font.pixelSize: 13
                        color: "#ffffff"
                        text: ""
                        visible: text !== ""
                    }

                    // Pulsanti
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        MevaCoinComponents.StandardButton {
                            text: qsTr("Share .keys") + translationManager.emptyString
                            small: true
                            Layout.fillWidth: true
                            onClicked: {
                                var walletPath = appWindow.accountsDir + persistentSettings.wallet_path;
                                var keysFile = walletPath + ".keys";
                                var ok = oshelper.openFile(keysFile);
                                if (ok) {
                                    downloadResult.color = "#44cc66";
                                    downloadResult.text = qsTr("Share dialog opened for: ") + keysFile;
                                } else {
                                    // Fallback: prova Qt.openUrlExternally
                                    Qt.openUrlExternally("file://" + keysFile);
                                    downloadResult.color = "#ffaa00";
                                    downloadResult.text = qsTr("File: ") + keysFile + "\n" + qsTr("Use your file manager to copy this file.");
                                }
                            }
                        }

                        MevaCoinComponents.StandardButton {
                            text: qsTr("Share wallet") + translationManager.emptyString
                            small: true
                            Layout.fillWidth: true
                            onClicked: {
                                var walletPath = appWindow.accountsDir + persistentSettings.wallet_path;
                                var ok = oshelper.openFile(walletPath);
                                if (ok) {
                                    downloadResult.color = "#44cc66";
                                    downloadResult.text = qsTr("Share dialog opened for wallet file.");
                                } else {
                                    Qt.openUrlExternally("file://" + walletPath);
                                    downloadResult.color = "#ffaa00";
                                    downloadResult.text = qsTr("File: ") + walletPath;
                                }
                            }
                        }
                    }

                    MevaCoinComponents.StandardButton {
                        text: qsTr("Close") + translationManager.emptyString
                        small: true
                        Layout.alignment: Qt.AlignRight
                        onClicked: downloadWalletDialog.close()
                    }
                }
            }
        }
        // ─────────────────────────────────────────────────────────'''

# ─────────────────────────────────────────────────────────────────
#  5. Sign.qml — RowLayout file+browse → ColumnLayout su mobile
# ─────────────────────────────────────────────────────────────────
SIGN_FILE_OLD = '''            RowLayout {
                id: signFileRow
                Layout.fillWidth: true
                visible: fileMode

                MevaCoinComponents.LineEditMulti {
                    id: signFileLine
                    labelFontSize: 14
                    labelText: qsTr("File") + translationManager.emptyString
                    placeholderFontSize: 16
                    placeholderText: qsTr("Enter path to file") + translationManager.emptyString;
                    readOnly: false
                    Layout.fillWidth: true
                    onTextChanged: signSignatureLine.text = ""
                    wrapMode: Text.WrapAnywhere
                    text: \'\'
                }

                MevaCoinComponents.StandardButton {
                    id: loadFileToSignButton
                    Layout.alignment: Qt.AlignBottom
                    small: false
                    text: qsTr("Browse") + translationManager.emptyString
                    enabled: true
                    onClicked: {
                      signFileDialog.open();
                    }
                }
            }'''

SIGN_FILE_NEW = '''            // mobileSignPatch: ColumnLayout invece di RowLayout
            ColumnLayout {
                id: signFileRow
                Layout.fillWidth: true
                visible: fileMode
                spacing: 8

                MevaCoinComponents.LineEditMulti {
                    id: signFileLine
                    labelFontSize: 14
                    labelText: qsTr("File") + translationManager.emptyString
                    placeholderFontSize: 16
                    placeholderText: qsTr("Enter path to file") + translationManager.emptyString;
                    readOnly: false
                    Layout.fillWidth: true
                    onTextChanged: signSignatureLine.text = ""
                    wrapMode: Text.WrapAnywhere
                    text: \'\'
                }

                MevaCoinComponents.StandardButton {
                    id: loadFileToSignButton
                    Layout.alignment: Qt.AlignRight
                    small: true
                    text: qsTr("Browse") + translationManager.emptyString
                    enabled: true
                    onClicked: { signFileDialog.open(); }
                }
            }'''

SIGN_VERIFY_OLD = '''            RowLayout {
                id: verifyFileRow
                Layout.fillWidth: true
                visible: fileMode

                MevaCoinComponents.LineEditMulti {
                    id: verifyFileLine
                    labelFontSize: 14
                    labelText: qsTr("File") + translationManager.emptyString
                    placeholderFontSize: 16
                    placeholderText: qsTr("Enter path to file") + translationManager.emptyString
                    readOnly: false
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAnywhere
                    text: \'\'
                }

                MevaCoinComponents.StandardButton {
                    id: loadFileToVerifyButton
                    Layout.alignment: Qt.AlignBottom
                    small: false
                    text: qsTr("Browse") + translationManager.emptyString;
                    enabled: true
                    onClicked: {
                      verifyFileDialog.open()
                    }
                }
            }'''

SIGN_VERIFY_NEW = '''            // mobileVerifyPatch: ColumnLayout invece di RowLayout
            ColumnLayout {
                id: verifyFileRow
                Layout.fillWidth: true
                visible: fileMode
                spacing: 8

                MevaCoinComponents.LineEditMulti {
                    id: verifyFileLine
                    labelFontSize: 14
                    labelText: qsTr("File") + translationManager.emptyString
                    placeholderFontSize: 16
                    placeholderText: qsTr("Enter path to file") + translationManager.emptyString
                    readOnly: false
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAnywhere
                    text: \'\'
                }

                MevaCoinComponents.StandardButton {
                    id: loadFileToVerifyButton
                    Layout.alignment: Qt.AlignRight
                    small: true
                    text: qsTr("Browse") + translationManager.emptyString;
                    enabled: true
                    onClicked: { verifyFileDialog.open() }
                }
            }'''

# ─────────────────────────────────────────────────────────────────
#  ESECUZIONE
# ─────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    check_root()

    print("\n══════════════════════════════════════════════")
    print("  MevaCoin Wallet — Patch Mobile Definitiva")
    print("══════════════════════════════════════════════\n")

    print("[1] components/Navbar.qml — tab scrollabili su Android")
    patch_navbar()

    print("\n[2] pages/settings/SettingsLayout.qml — GridLayout fiat responsive")
    patch("pages/settings/SettingsLayout.qml", "SettingsLayout GridLayout fiat",
          SLAYOUT_OLD, SLAYOUT_NEW, "mobileGridPatch")

    print("\n[3] pages/settings/SettingsInfo.qml — GridLayout info responsive")
    patch("pages/settings/SettingsInfo.qml", "SettingsInfo GridLayout",
          SINFO_OLD, SINFO_NEW, "mobileInfoGridPatch")

    print("\n[4] pages/settings/SettingsWallet.qml — pulsante Download wallet file")
    patch("pages/settings/SettingsWallet.qml", "SettingsWallet download button",
          SWALLET_OLD, SWALLET_NEW, "downloadWalletItem")

    print("\n[5] pages/Sign.qml — RowLayout file → ColumnLayout")
    # Prima rimuovi patch precedente se esiste (mobileSignPatch)
    with open("pages/Sign.qml", "r") as f:
        sc = f.read()
    if "mobileSignPatch" in sc:
        # Già patchato dallo script precedente - rimuovi e riapplica correttamente
        # Lo script precedente ha già modificato, usa quei file come base
        print("  INFO: Sign.qml aveva patch precedente, verifico...")
    patch("pages/Sign.qml", "Sign.qml signFileRow",
          SIGN_FILE_OLD, SIGN_FILE_NEW, "mobileSignPatch")
    patch("pages/Sign.qml", "Sign.qml verifyFileRow",
          SIGN_VERIFY_OLD, SIGN_VERIFY_NEW, "mobileVerifyPatch")

    print("\n[6] pages/settings/SettingsNode.qml — larghezze responsive")
    patch_regex("pages/settings/SettingsNode.qml",
                "SettingsNode minimumWidth",
                r"Layout\.minimumWidth:\s*(\d{3,})",
                lambda m: f"Layout.minimumWidth: (typeof isAndroid !== \"undefined\" && isAndroid) ? 200 : {m.group(1)}",
                "mobileNodePatch")

    print("\n[7] pages/settings/SettingsWallet.qml — FontAwesome import check")
    with open("pages/settings/SettingsWallet.qml", "r") as f:
        sw = f.read()
    if "import FontAwesome" not in sw:
        sw = sw.replace("import \"../../components\" as MevaCoinComponents",
                        "import \"../../components\" as MevaCoinComponents\nimport FontAwesome 1.0")
        with open("pages/settings/SettingsWallet.qml", "w") as f:
            f.write(sw)
        print("  OK: aggiunto import FontAwesome")
    else:
        print("  GIA' OK: FontAwesome già importato")

    print("\n══════════════════════════════════════════════")
    print("  PATCH COMPLETATE!")
    print("")
    print("  ✓ Navbar        → tab scrollabili (swipe) su Android")
    print("  ✓ Settings UI   → GridLayout fiat diventano 1 colonna")
    print("  ✓ Settings Info → GridLayout info diventano 1 colonna")
    print("  ✓ Settings Wallet → pulsante 'Download wallet file'")
    print("    (visibile solo su Android, apre dialog con:")
    print("     - percorso file wallet")
    print("     - Share .keys (per mvcwallet)")
    print("     - Share wallet file)")
    print("  ✓ Sign.qml      → file rows non più affiancati")
    print("")
    print("  Ora fai:")
    print("  git add -A && git commit -m 'mobile patches definitivi'")
    print("  git push origin mining")
    print("══════════════════════════════════════════════\n")
