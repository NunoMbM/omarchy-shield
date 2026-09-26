import Quickshell
import QtQuick

PanelWindow {
    anchors {
        top: true
        right: true
    }
    margins {
        top: 8
        right: 16
    }
    implicitWidth: 160
    implicitHeight: 36
    color: "transparent"

    ShieldWidget {
        anchors.centerIn: parent
    }
}
