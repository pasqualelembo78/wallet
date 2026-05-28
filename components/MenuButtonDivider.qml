import QtQuick 2.9

import "." as MevaCoinComponents
import "effects/" as MevaCoinEffects

Rectangle {
    color: MevaCoinComponents.Style.appWindowBorderColor
    height: 1

    MevaCoinEffects.ColorTransition {
        targetObj: parent
        blackColor: MevaCoinComponents.Style._b_appWindowBorderColor
        whiteColor: MevaCoinComponents.Style._w_appWindowBorderColor
    }
}
