import QtQuick 2.9

import "../components" as MevaCoinComponents

TextEdit {
    color: MevaCoinComponents.Style.defaultFontColor
    font.family: MevaCoinComponents.Style.fontRegular.name
    selectionColor: MevaCoinComponents.Style.textSelectionColor
    wrapMode: Text.Wrap
    readOnly: true
    selectByMouse: true
    // Workaround for https://bugreports.qt.io/browse/QTBUG-50587
    onFocusChanged: {
        if(focus === false)
            deselect()
    }
}
