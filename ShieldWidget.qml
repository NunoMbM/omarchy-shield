import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: barPill.implicitWidth
    implicitHeight: 32

    // Live Telemetry State (Read-only from JSON)
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

    // UI State
    property bool deckOpen: false
    property int configuredLeaseMins: 60

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

    // 1. Unprivileged Telemetry Polling
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

                    // Imperatively sync UI controls without breaking Qt6 bindings
                    if (!ptraceSlider.pressed) {
                        ptraceSlider.value = data.ptrace;
                    }
                    if (!devPortsSwitch.down) {
                        devPortsSwitch.checked = (data.dev_ports === 1);
                    }
                } catch (e) {
                    console.warn("OmarchyShield telemetry parse error:", e);
                }
            }
        }
    }

    // 2. Privileged Action Runner
    Process {
        id: actionProc
        onExited: (code, status) => {
            telemetryProc.running = true;
        }
    }

    // Called ONLY when clicking one of the 3 Mode Preset buttons
    function selectModePreset(targetMode) {
        let defaultPtrace = (targetMode === "public") ? 2 : 1;
        let defaultPorts = (targetMode === "public") ? "0" : (devPortsSwitch.checked ? "1" : "0");
        let leaseArg = (targetMode === "lab") ? root.configuredLeaseMins.toString() : "0";

        ptraceSlider.value = defaultPtrace;
        if (targetMode === "public") {
            devPortsSwitch.checked = false;
        }

        actionProc.command = [
            "/usr/bin/omarchy-shield-ctl",
            "apply",
            targetMode,
            defaultPtrace.toString(),
            leaseArg,
            defaultPorts
        ];
        actionProc.running = true;
    }

    // Called when adjusting sliders/switches inside an active mode
    function updateLiveParameters(rearmLease) {
        let targetPtrace = Math.round(ptraceSlider.value).toString();
        let targetPorts = devPortsSwitch.checked ? "1" : "0";
        let leaseArg = "keep";

        if (rearmLease && root.currentMode === "lab") {
            leaseArg = root.configuredLeaseMins.toString();
        }

        actionProc.command = [
            "/usr/bin/omarchy-shield-ctl",
            "apply",
            root.currentMode,
            targetPtrace,
            leaseArg,
            targetPorts
        ];
        actionProc.running = true;
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: telemetryProc.running = true
    }

    // -------------------------------------------------------------------------
    // TOP BAR PILL
    // -------------------------------------------------------------------------
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

    // -------------------------------------------------------------------------
    // POPUP CONTROL DECK
    // -------------------------------------------------------------------------
    FloatingWindow {
        id: deckWindow
        visible: root.deckOpen
        title: "Omarchy Shield"
        implicitWidth: 390
        implicitHeight: 500
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

                // 1. Mode Presets
                Text { text: "1. Security & Hardware Profile"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Button {
                        Layout.fillWidth: true
                        text: "Public / Travel"
                        highlighted: root.currentMode === "public"
                        onClicked: root.selectModePreset("public")
                    }
                    Button {
                        Layout.fillWidth: true
                        text: "Workstation"
                        highlighted: root.currentMode === "daily"
                        onClicked: root.selectModePreset("daily")
                    }
                    Button {
                        Layout.fillWidth: true
                        text: "Lab & Gaming"
                        highlighted: root.currentMode === "lab"
                        onClicked: root.selectModePreset("lab")
                    }
                }

                // 2. Lease Timer Slider (Only resets timer when user releases this specific slider)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Lab Lease Duration:"
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                        }
                        Text {
                            text: root.configuredLeaseMins === 0
                                ? "Until Reboot"
                                : root.configuredLeaseMins + " min" + (root.currentMode === "lab" && root.leaseRemaining > 0 ? " (" + root.leaseRemaining + "m left)" : "")
                            color: "#f59e0b"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                    Slider {
                        id: leaseSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 240
                        stepSize: 15
                        Component.onCompleted: value = root.configuredLeaseMins
                        onMoved: root.configuredLeaseMins = Math.round(value)
                        onPressedChanged: {
                            if (!pressed && root.currentMode === "lab") {
                                root.updateLiveParameters(true);
                            }
                        }
                    }
                }

                // 3. Process Isolation Slider (Works in Daily and Lab without resetting lease)
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
                            text: Math.round(ptraceSlider.value) === 2 ? "Level 2 (Strict)" : "Level 1 (GDB/Proton)"
                            color: "#89b4fa"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                    Slider {
                        id: ptraceSlider
                        Layout.fillWidth: true
                        from: 1
                        to: 2
                        stepSize: 1
                        enabled: root.currentMode !== "public"
                        Component.onCompleted: value = root.ptraceScope
                        onPressedChanged: {
                            if (!pressed) {
                                root.updateLiveParameters(false);
                            }
                        }
                    }
                }

                // 4. Local MCU / Dev Ports Switch (Preserves lease timer)
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Open MCU/Debug Ports (1883 MQTT / 3333 OpenOCD)"
                        color: "#cdd6f4"
                        font.pixelSize: 12
                        Layout.fillWidth: true
                    }
                    Switch {
                        id: devPortsSwitch
                        enabled: root.currentMode !== "public"
                        Component.onCompleted: checked = (root.devPortsActive === 1)
                        onClicked: root.updateLiveParameters(false)
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

                // 5. Live Telemetry Matrix
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

                // 6. Quick Actions
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
