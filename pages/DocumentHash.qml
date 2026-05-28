import QtQuick 2.9; import QtQuick.Controls 1.4; import QtQuick.Layouts 1.1; import QtQuick.Dialogs 1.2
import "../components" as MevaCoinComponents; import mevacoinComponents.Clipboard 1.0; import mevacoinComponents.DocumentHashHelper 1.0
ColumnLayout { id:root; Layout.fillWidth:true; spacing:0; property alias documentHashHeight:ml.height
  Clipboard{id:clip} DocumentHashHelper{id:hh}
  property string currentHash:""; property string currentFileName:""; property bool busy:false
  ColumnLayout{id:ml;Layout.fillWidth:true;Layout.margins:20;spacing:16
    MevaCoinComponents.Label{Layout.fillWidth:true;fontSize:24;text:qsTr("Document Hash")+translationManager.emptyString}
    MevaCoinComponents.TextPlain{Layout.fillWidth:true;wrapMode:Text.WordWrap;font.pixelSize:14;color:MevaCoinComponents.Style.dimmedFontColor;text:qsTr("Timestamp documents on MevaCoin blockchain. Compute SHA-256 hash and embed permanently as proof of existence.")+translationManager.emptyString}
    MevaCoinComponents.Label{Layout.topMargin:10;fontSize:16;text:qsTr("1. Select a file to hash")+translationManager.emptyString}
    RowLayout{Layout.fillWidth:true;spacing:10
      MevaCoinComponents.StandardButton{text:qsTr("Choose file...")+translationManager.emptyString;enabled:!busy;onClicked:fd.open()}
      MevaCoinComponents.TextPlain{Layout.fillWidth:true;font.pixelSize:14;elide:Text.ElideMiddle;color:currentFileName?MevaCoinComponents.Style.defaultFontColor:MevaCoinComponents.Style.dimmedFontColor;text:currentFileName?currentFileName:qsTr("No file selected")+translationManager.emptyString}
    }
    FileDialog{id:fd;title:qsTr("Select document");selectMultiple:false;onAccepted:{var p=fd.fileUrl.toString();currentFileName=p.split("/").pop();busy=true;var h=hh.sha256File(p);currentHash=(h.length===64)?h:"";if(!currentHash)appWindow.showStatusMessage(qsTr("Error computing hash"),5);busy=false}}
    MevaCoinComponents.Label{Layout.topMargin:8;fontSize:16;text:qsTr("Or enter SHA-256 manually")+translationManager.emptyString}
    MevaCoinComponents.LineEdit{id:mi;Layout.fillWidth:true;placeholderText:"64 hex characters...";fontSize:14;onTextChanged:{if(text.length===64&&/^[0-9a-fA-F]{64}$/.test(text)){currentHash=text.toLowerCase();currentFileName=qsTr("(manual)")}}}
    Rectangle{Layout.fillWidth:true;Layout.preferredHeight:hc.height+30;color:MevaCoinComponents.Style.blackTheme?"#1a1a2e":"#f0f0f0";radius:8;visible:currentHash.length===64
      ColumnLayout{id:hc;anchors.left:parent.left;anchors.right:parent.right;anchors.top:parent.top;anchors.margins:15;spacing:8
        MevaCoinComponents.Label{fontSize:14;fontBold:true;text:"SHA-256:"}
        RowLayout{Layout.fillWidth:true;spacing:8
          MevaCoinComponents.TextPlain{Layout.fillWidth:true;text:currentHash;font.family:"monospace";font.pixelSize:12;wrapMode:Text.WrapAnywhere;color:MevaCoinComponents.Style.defaultFontColor}
          MevaCoinComponents.InlineButton{fontPixelSize:12;text:qsTr("Copy");onClicked:{clip.setText(currentHash);appWindow.showStatusMessage(qsTr("Copied"),3)}}
        }
        MevaCoinComponents.TextPlain{visible:currentFileName.length>0;text:qsTr("File: %1").arg(currentFileName);font.pixelSize:12;color:MevaCoinComponents.Style.dimmedFontColor}
      }
    }
    MevaCoinComponents.Label{Layout.topMargin:12;fontSize:16;text:qsTr("2. Embed in blockchain");visible:currentHash.length===64}
    MevaCoinComponents.TextPlain{Layout.fillWidth:true;wrapMode:Text.WordWrap;visible:currentHash.length===64;font.pixelSize:14;color:MevaCoinComponents.Style.dimmedFontColor;text:qsTr("Sends minimal self-transaction with hash in tx_extra. Fees apply.")}
    MevaCoinComponents.StandardButton{Layout.topMargin:4;text:qsTr("Timestamp on Blockchain");visible:currentHash.length===64;enabled:currentHash.length===64&&!busy&&appWindow.currentWallet!==undefined;onClicked:cdlg.open()}
    Rectangle{Layout.fillWidth:true;Layout.preferredHeight:1;Layout.topMargin:20;color:MevaCoinComponents.Style.dividerColor}
    MevaCoinComponents.Label{Layout.topMargin:12;fontSize:16;text:qsTr("Verify a document")+translationManager.emptyString}
    MevaCoinComponents.TextPlain{Layout.fillWidth:true;wrapMode:Text.WordWrap;font.pixelSize:14;color:MevaCoinComponents.Style.dimmedFontColor;text:qsTr("Compare file hash against expected hash.")}
    MevaCoinComponents.LineEdit{id:vi;Layout.fillWidth:true;placeholderText:qsTr("Expected SHA-256 (64 hex)");fontSize:14}
    RowLayout{spacing:10
      MevaCoinComponents.StandardButton{text:qsTr("Verify file");enabled:vi.text.length===64;onClicked:vfd.open()}
      MevaCoinComponents.StandardButton{text:qsTr("Clear");onClicked:{vi.text="";vb.visible=false;currentHash="";currentFileName="";mi.text=""}}
    }
    FileDialog{id:vfd;title:qsTr("Select file to verify");selectMultiple:false;onAccepted:{vb.matches=hh.verifyFileHash(vfd.fileUrl.toString(),vi.text);vb.visible=true}}
    Rectangle{id:vb;Layout.fillWidth:true;Layout.preferredHeight:50;radius:8;visible:false;property bool matches:false;color:matches?(MevaCoinComponents.Style.blackTheme?"#0d3320":"#d4edda"):(MevaCoinComponents.Style.blackTheme?"#330d0d":"#f8d7da")
      MevaCoinComponents.TextPlain{anchors.centerIn:parent;font.bold:true;font.pixelSize:14;color:vb.matches?"#28a745":"#dc3545";text:vb.matches?qsTr("MATCH - Verified"):qsTr("MISMATCH - Modified")}
    }
  }
  MessageDialog{id:cdlg;title:qsTr("Confirm Timestamping");text:qsTr("Embed hash in blockchain? Fees apply.");standardButtons:StandardButton.Yes|StandardButton.No;onYes:{if(appWindow.currentWallet){busy=true;appWindow.currentWallet.createDocumentHashTransactionAsync(currentHash);appWindow.showStatusMessage(qsTr("Creating transaction..."),5)}}}
  Connections{target:appWindow.currentWallet;function onDocumentHashTransactionCreated(tx,h){busy=false;if(tx&&tx.status===PendingTransaction.Status_Ok){appWindow.currentWallet.commitTransactionAsync(tx);appWindow.showStatusMessage(qsTr("Hash submitted!"),8)}else{appWindow.showStatusMessage(qsTr("Error: ")+(tx?tx.errorString:"unknown"),8)}}}
}
