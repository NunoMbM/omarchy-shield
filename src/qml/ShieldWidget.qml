import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: barPill.implicitWidth
    implicitHeight: 32

    property string currentMode: "daily"
    property int ptraceScope: 1
    property int dmesgRestrict: 1
    property string lockdownState: "integrity"
    property string secureBootState: "OFF"
    property string luksState: "ENCRYPTED"
    property string sudoState: "LOCKED"
    property int openPorts: 0
    property int devPortsActive: 0
    property int leaseRemaining: 0

    property bool deckOpen: false
    property int selectedLeaseMins: 60
    property int selectedPtrace: 1
    property bool selectedDevPorts: false

    function modeLabel() {
        if (currentMode === "public") return "PUBLIC LOCK";
        if (currentMode === "lab") return leaseRemaining > 0 ? "LAB (" + leaseRemaining + "m)" : "LAB & GAME";
        return "WORKSTATION";
    }

    function modeColor() {
        if (sudoState === "EXPOSED") return "#ef4444";
        if (currentMode === "public") return "#38bdf8";
        if (currentMode === "lab") return "#f59e0b";
        return "#10b981";
    }

    Process {
        id: telemetryProc
        command: ["/usr/bin/omarchy-shield-ctl", "status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text.trim());
                    root.currentMode = data.mode;
                    root.ptraceScope = data.ptrace;
                    root.dmesgRestrict = data.dmesg;
                    root.lockdownState = data.lockdown;
                    root.secureBootState = data.secure_boot;
                    root.luksState = data.luks;
                    root.sudoState = data.sudo_state;
                    root.openPorts = data.open_ports;
                    root.devPortsActive = data.dev_ports;
                    root.leaseRemaining = data.lease_rem;
                } catch (e) {
                    console.warn("OmarchyShield telemetry parse error:", e);
                }
            }
        }
    }

    Process {
        id: actionProc
        onExited: (code, status) => {
            telemetryProc.running = true;
        }
    }

    function applyProfile(targetMode) {
        if (targetMode === "public") {
            root.selectedPtrace = 2;
            root.selectedDevPorts = false;
        } else if (targetMode === "daily" && root.selectedPtrace === 2) {
            root.selectedPtrace = 1;
        } else if (targetMode === "lab") {
            root.selectedPtrace = 1;
        }
        actionProc.command = [
            "/usr/bin/omarchy-shield-ctl",
            "apply",
            targetMode,
            root.selectedPtrace.toString(),
            (targetMode === "lab" ? root.selectedLeaseMins : 0).toString(),
            (root.selectedDevPorts ? "1" : "0")
        ];
        actionProc.running = true;
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: telemetryProc.running = true
    }

    Rectangle {
        id: barPill
        anchors.fill: parent
        implicitWidth: pillRow.implicitWidth + 20
        radius: 6
        color: "#1e1e2e"
        border.color: root.modeColor()
        border.width: 1

        RowLayout {
            id: pillRow
            anchors.centerIn: parent
            spacing: 8

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: root.modeColor()
            }

            Text {
                text: root.modeLabel()
                color: "#cdd6f4"
                font.pixelSize: 12
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.deckOpen = !root.deckOpen
        }
    }

    FloatingWindow {
        id: deckWindow
        visible: root.deckOpen
        title: "Omarchy Shield"
        implicitWidth: 380
        implicitHeight: 490
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: "#181825"
            border.color: "#313244"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "OMARCHY SHIELD // SECURITY DECK"
                        color: "#cdd6f4"
                        font.pixelSize: 13
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "✕"
                        flat: true
                        onClicked: root.deckOpen = false
                    }
                }

                Text { text: "1. Security & Hardware Profile"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Button {
                        Layout.fillWidth: true
                        text: "Public / Travel"
                        highlighted: root.currentMode === "public"
                        onClicked: root.applyProfile("public")
                    }
                    Button {
                        Layout.fillWidth: true
                        text: "Workstation"
                        highlighted: root.currentMode === "daily"
                        onClicked: root.applyProfile("daily")
                    }
                    Button {
                        Layout.fillWidth: true
                        text: "Lab & Gaming"
                        highlighted: root.currentMode === "lab"
                        onClicked: root.applyProfile("lab")
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Auto-Revert Lease Timer (Lab Mode):"
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                        }
                        Text {
                            text: root.selectedLeaseMins === 0 ? "Until Reboot" : root.selectedLeaseMins + " min"
                            color: "#f59e0b"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                    Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: 240
                        stepSize: 15
                        value: root.selectedLeaseMins
                        onMoved: root.selectedLeaseMins = Math.round(value)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Process Memory Isolation (ptrace):"
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                        }
                        Text {
                            text: root.selectedPtrace === 2 ? "Level 2 (Strict)" : "Level 1 (GDB/Proton)"
                            color: "#89b4fa"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                    Slider {
                        Layout.fillWidth: true
                        from: 1
                        to: 2
                        stepSize: 1
                        value: root.selectedPtrace
                        onMoved: {
                            root.selectedPtrace = Math.round(value);
                            root.applyProfile(root.currentMode);
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Open MCU/Debug Ports (1883 MQTT / 3333 OpenOCD)"
                        color: "#cdd6f4"
                        font.pixelSize: 12
                        Layout.fillWidth: true
                    }
                    Switch {
                        checked: root.devPortsActive === 1
                        onToggled: {
                            root.selectedDevPorts = checked;
                            root.applyProfile(root.currentMode);
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

                Text { text: "2. Live Kernel & Boot Telemetry"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 6
                    columnSpacing: 12

                    Text { text: "Kernel Lockdown:"; color: "#a6adc8"; font.pixelSize: 12 }
                    Text { text: root.lockdownState.toUpperCase(); color: "#a6e3a1"; font.pixelSize: 12; font.bold: true }

                    Text { text: "USB dmesg Logs:"; color: "#a6adc8"; font.pixelSize: 12 }
                    Text {
                        text: root.dmesgRestrict === 0 ? "UNLOCKED (Lab)" : "RESTRICTED (Root Only)"
                        color: root.dmesgRestrict === 0 ? "#f9e2af" : "#a6e3a1"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text { text: "Listening Sockets:"; color: "#a6adc8"; font.pixelSize: 12 }
                    Text { text: root.openPorts + " non-loopback"; color: "#cdd6f4"; font.pixelSize: 12; font.bold: true }

                    Text { text: "Sudo / AI Agent Cache:"; color: "#a6adc8"; font.pixelSize: 12 }
                    Text {
                        text: root.sudoState
                        color: root.sudoState === "EXPOSED" ? "#f38ba8" : "#a6e3a1"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text { text: "Disk / Secure Boot:"; color: "#a6adc8"; font.pixelSize: 12 }
                    Text {
                        text: root.luksState + " / SB: " + root.secureBootState
                        color: "#89b4fa"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        Layout.fillWidth: true
                        text: "Revoke Sudo / AI Cache"
                        onClicked: {
                            actionProc.command = ["/usr/bin/omarchy-shield-ctl", "revoke-sudo"];
                            actionProc.running = true;
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: "Reboot to UEFI"
                        onClicked: {
                            actionProc.command = ["/usr/bin/omarchy-shield-ctl", "bios"];
                            actionProc.running = true;
                        }
                    }
                }
            }
        }
    }
}
