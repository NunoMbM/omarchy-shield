# Omarchy-shield
Omarchy plugin to improve security 


[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Omarchy 4 Quattro](https://img.shields.io/badge/Omarchy_4-Quattro-10b981?style=for-the-badge)](https://omarchy.org/)
[![Quickshell](https://img.shields.io/badge/Quickshell-Qt6_QML-89b4fa?style=for-the-badge&logo=qt&logoColor=white)](https://quickshell.org/)
[![Polkit Hardened](https://img.shields.io/badge/Privilege-Polkit_pkexec-f59e0b?style=for-the-badge)](https://wiki.archlinux.org/title/Polkit)
[![License: MIT](https://img.shields.io/badge/License-MIT-a6e3a1?style=for-the-badge)](LICENSE)

**Context-aware kernel security, USB hardware debugger policy, and firewall profile switcher for Omarchy 4 (Quattro) and Quickshell.**

`omarchy-shield` bridges the gap between strict Linux kernel hardening and daily engineering/gaming workflows. Instead of permanently weakening your system to use hardware debuggers (`probe-rs`, `OpenOCD`, `gdb`), serial monitors (`dmesg`), or Steam Proton—or leaving your laptop exposed on public Wi-Fi—`omarchy-shield` provides a native Quickshell bar widget with **one-click security presets**, **timed auto-revert leases**, and **live privilege telemetry**.

---

## UI Layout (`FloatingWindow` Security Deck)

```text
┌──────────────────────────────────────────────────────────┐
│ OMARCHY SHIELD // SECURITY DECK                      [✕] │
├──────────────────────────────────────────────────────────┤
│ 1. Security & Hardware Profile                           │
│  [ Public / Travel ]  [ Workstation ]  [ Lab & Gaming ]  │
│                                                          │
│ Lab Lease Duration:                     60 min (58m left)│
│ ━━━━━━━━━━●━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                          │
│ Process Memory Isolation (ptrace):  Level 1 (GDB/Proton) │
│ ●━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                          │
│ Open MCU/Debug Ports (1883 MQTT / 3333 OpenOCD)    [OFF] │
├──────────────────────────────────────────────────────────┤
│ 2. Live Kernel & Boot Telemetry                          │
│  Kernel Lockdown:      INTEGRITY                         │
│  USB dmesg Logs:       RESTRICTED (Root Only)            │
│  Listening Sockets:    1 non-loopback                    │
│  Sudo / AI Cache:      LOCKED                            │
│  Disk / Secure Boot:   ENCRYPTED / SB: ON                │
│                                                          │
│  [ Revoke Sudo / AI Cache ]           [ Reboot to UEFI ] │
└──────────────────────────────────────────────────────────┘
```

---

##  Key Features

* **Three Context-Aware Security Presets:** Switch between **Public / Travel** (strict lockdown), **Daily Workstation** (balanced hardened), and **Lab & Gaming** (hardware & debug unlocked).
* **Timed Auto-Revert Leases:** Entering **Lab & Gaming** mode starts a transient `systemd-run` countdown (`15m` to `240m`). Tuning `ptrace` or firewall ports mid-session preserves the active countdown (`keep` flag), and when the timer expires, your system automatically reverts to **Daily Workstation** mode with a desktop notification.
* **USB Debug Probe Wake Lock:** Disables Linux USB autosuspend (`power/control = on`) while in **Lab & Gaming** mode so ST-Link, J-Link, CMSIS-DAP, ESP32 USB-JTAG bridges, and game controllers do not disconnect mid-session.
* **AI Agent & Passwordless Sudo Killswitch:** Detects if `sudo` credentials are cached or if `/etc/sudoers.d/omarchy-passwordless` is active, turning the top-bar indicator **Red** with a 1-click revoke button.
* **Strict Privilege Separation & Input Validation:** Telemetry polling runs 100% unprivileged (`0.0% CPU`, `< 5 MB RAM`). Privileged actions execute through `/usr/bin/omarchy-shield-ctl` gated by Polkit (`auth_admin` without cached credential windows) and strict argument validation.

---

##  Profile Matrix

| Parameter / Subsystem |  `Public / Travel` |  `Daily Workstation` *(Default)* |  `Lab & Gaming` *(Timed Lease)* |
| :--- | :--- | :--- | :--- |
| **Process Memory Attach (`yama.ptrace_scope`)** | `2` *(Admin Only — Locked)* | `1` *(Configurable `1` or `2`)* | `1` *(Configurable `1` or `2`)* |
| **Kernel Ring Buffer (`kernel.dmesg_restrict`)** | `1` *(Hidden from user apps)* | `1` *(Hidden from user apps)* | `0` *(Unlocked for live `dmesg -w` USB logs)* |
| **Kernel Address Exposure (`kptr_restrict`)** | `2` *(Strict KASLR protection)* | `2` *(Strict KASLR protection)* | `2` *(Strict KASLR protection)* |
| **USB Autosuspend (`power/control`)** | `auto` *(Battery saving)* | `auto` *(Battery saving)* | `on` *(Keeps JTAG/SWD probes awake)* |
| **MCU / Debug Firewall Ports (`ufw`)** | Closed (`deny incoming`) | Optional (`1883` / `3333`) | Optional (`1883` MQTT / `3333` OpenOCD) |
| **Sudo / AI Passwordless Cache** | Purged immediately on entry | Monitored live | Monitored live |

---

##  Installation

### Option 1: Install from Source (`makepkg`)

Clone the repository, generate the SHA-256 checksums, and build with `makepkg`:

```bash
git clone https://github.com/NunoMbM/omarchy-shield.git
cd omarchy-shield
makepkg -si
```


##  Setup & Quickshell Integration

### 1. Test the Widget Standalone
```bash
# Verify JSON telemetry output (unprivileged)
omarchy-shield-ctl status

# Launch standalone floating bar window
quickshell -p /usr/share/quickshell/omarchy-shield/shell.qml
```

### 2. Embed into Your Omarchy Quickshell Bar
Import `/usr/share/quickshell/omarchy-shield` inside your main `~/.config/quickshell/shell.qml` and add `ShieldWidget {}` to your bar layout:

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import "/usr/share/quickshell/omarchy-shield"

PanelWindow {
    RowLayout {
        ShieldWidget {}
    }
}
```

---

##  CLI Subcommands & Hyprland Keybinds

`omarchy-shield-ctl` supports four subcommands (`status`, `apply`, `revoke-sudo`, and `bios`):

```bash
# Print live JSON telemetry (unprivileged)
omarchy-shield-ctl status

# Apply Public / Travel lockdown
omarchy-shield-ctl apply public 2 0 0

# Apply Daily Workstation mode (ptrace=1, lease=0, dev_ports=0)
omarchy-shield-ctl apply daily 1 0 0

# Apply Lab & Gaming mode with a 60-minute auto-revert lease and OpenOCD/MQTT ports open
omarchy-shield-ctl apply lab 1 60 1

# Update ptrace to Level 2 inside Lab mode WITHOUT resetting the running lease timer ('keep')
omarchy-shield-ctl apply lab 2 keep 1

# Revoke cached sudo credentials and remove /etc/sudoers.d/omarchy-passwordless
omarchy-shield-ctl revoke-sudo
```

Example Hyprland keybinds (`~/.config/hypr/hyprland.conf`):

```ini
bind = SUPER SHIFT, S, exec, omarchy-shield-ctl apply public 2 0 0
bind = SUPER SHIFT, L, exec, omarchy-shield-ctl apply lab 1 60 0
```

---

##  Security Model Notes

* **Pre-Escalation Validation & Polkit Granularity:** Positional arguments are validated against a strict whitelist (`public|daily|lab`, `ptrace` `1|2`, `lease` `0-240|keep`, `dev_ports` `0|1`) before invoking `pkexec`. Polkit authorizes `/usr/bin/omarchy-shield-ctl` using `auth_admin`(no cached authentication window).
* **Whole-Binary Authorization Limitation (`pkexec`):** Because Polkit's `org.freedesktop.policykit.exec.path` mechanism binds authorization to the executable path (`/usr/bin/omarchy-shield-ctl`) rather than individual CLI subcommands, authenticating as an administrator permits execution of any valid subcommand (`apply`, `revoke-sudo`, or `bios`). Subcommand-level separation would require splitting each action into dedicated helper binaries or shipping custom JavaScript Polkit rules in `/usr/share/polkit-1/rules.d/`.
* **Boot-Level Hardening:** For full kernel lockdown (`lockdown=integrity`) and heap zeroing (`init_on_alloc=1`), add `lsm=landlock,lockdown,yama,integrity,apparmor,bpf lockdown=integrity init_on_alloc=1` to `KERNEL_CMDLINE[default]` in `/etc/default/limine` and run `sudo limine-update`.

---

##  License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for details.

