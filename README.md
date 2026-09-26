# omarchy-shield
Omarchy plugin to improve security 

#  omarchy-shield

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Omarchy 4 Quattro](https://img.shields.io/badge/Omarchy_4-Quattro-10b981?style=for-the-badge)](https://omarchy.org/)
[![Quickshell](https://img.shields.io/badge/Quickshell-Qt6_QML-89b4fa?style=for-the-badge&logo=qt&logoColor=white)](https://quickshell.org/)
[![Polkit Hardened](https://img.shields.io/badge/Privilege-Polkit_pkexec-f59e0b?style=for-the-badge)](https://wiki.archlinux.org/title/Polkit)
[![License: MIT](https://img.shields.io/badge/License-MIT-a6e3a1?style=for-the-badge)](LICENSE)

**Context-aware kernel security, USB hardware debugger policy, and firewall profile switcher for Omarchy 4 (Quattro) and Quickshell.**

`omarchy-shield` bridges the gap between strict Linux kernel hardening and daily engineering/gaming workflows. Instead of permanently weakening your system to use hardware debuggers (`probe-rs`, `OpenOCD`, `gdb`), serial monitors (`dmesg`), or Steam Proton—or leaving your laptop exposed on public Wi-Fi—`omarchy-shield` gives you a native Quickshell bar widget with **one-click security presets**, **timed auto-revert leases**, and **live privilege telemetry**.

---

##  Preview & UI Layout

> *Replace the paths below with screenshots of your bar pill and popup deck once uploaded to your repository's `assets/` folder.*

| Top Bar Indicator Pills | Interactive Security Deck (`FloatingWindow`) |
| :---: | :---: |
| ![Bar Pill Preview](assets/bar-pills-preview.png) | ![Security Deck Preview](assets/security-deck-preview.png) |

```text
┌──────────────────────────────────────────────────────────┐
│ OMARCHY SHIELD // SECURITY DECK                      [✕] │
├──────────────────────────────────────────────────────────┤
│ 1. Security & Hardware Profile                           │
│  [ Public / Travel ]  [ Workstation ]  [ Lab & Gaming ]  │
│                                                          │
│ Auto-Revert Lease Timer (Lab Mode):               60 min │
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

* **Three Context-Aware Security Modes:** Switch instantly between **Public / Travel** (maximum lockdown), **Daily Workstation** (balanced hardened), and **Lab & Gaming** (hardware & debug unlocked).
* **Timed Auto-Revert Leases (Dead-Man Switch):** Unlocking `dmesg` or hardware ports in **Lab & Gaming** mode starts a transient `systemd-run` countdown (`15m` to `240m`). When the timer expires, your system automatically locks back down to **Daily Workstation** mode.
* **USB Debug Probe Wake Lock:** Automatically disables Linux USB autosuspend (`power/control = on`) while in **Lab & Gaming** mode so ST-Link, J-Link, CMSIS-DAP, ESP32 USB-JTAG bridges, and game controllers never drop connections mid-session.
* **AI Agent & Passwordless Sudo Killswitch:** Detects if `sudo` credentials are cached or if Omarchy 4's `passwordless sudo` rule for AI coding agents is active, turning the top-bar indicator **Red** with a 1-click revoke button.
* **Strict Privilege Separation (No Sudoers Hacks):** Telemetry runs 100% unprivileged (`0.0% CPU`, `< 5 MB RAM`). Kernel and firewall mutations execute through a `root:root` binary (`/usr/bin/omarchy-shield-ctl`) gated by Polkit (`pkexec` with `auth_admin_keep`).

---

##  Profile Matrix

| Parameter / Subsystem |  `Public / Travel` |  `Daily Workstation` *(Default)* |  `Lab & Gaming` *(Timed Lease)* |
| :--- | :--- | :--- | :--- |
| **Process Memory Attach (`yama.ptrace_scope`)** | `2` *(Admin Only — Blocks all ptrace)* | `1` *(Allows GDB & Steam Proton)* | `1` *(Allows `probe-rs`, `OpenOCD`, Proton)* |
| **Kernel Ring Buffer (`kernel.dmesg_restrict`)** | `1` *(Hidden from user apps)* | `1` *(Hidden from user apps)* | `0` *(Unlocked for live `dmesg -w` USB logs)* |
| **Kernel Address Exposure (`kptr_restrict`)** | `2` *(Strict KASLR protection)* | `2` *(Strict KASLR protection)* | `2` *(Strict KASLR protection)* |
| **USB Autosuspend (`power/control`)** | `auto` *(Battery saving)* | `auto` *(Battery saving)* | `on` *(Keeps JTAG/SWD probes awake)* |
| **MCU / Debug Firewall Ports (`ufw`)** | Closed (`deny incoming`) | Closed *( unless toggled )* | Optional 1-click `1883` (MQTT) & `3333` (OpenOCD) |
| **Sudo / AI Passwordless Cache** | Purged immediately on entry | Monitored live | Monitored live |

---

##  Installation

### Option 1: Install via AUR Helper (`yay` / `paru`)

Once published to the Arch User Repository (AUR), install directly with:

```bash
yay -S omarchy-shield
# or
paru -S omarchy-shield
```

### Option 2: Manual Build from Source (`makepkg`)

 follows standard Arch Linux packaging guidelines—no `curl | sh` scripts or untracked files in `/usr/local`:

```bash
git clone [https://github.com/yourusername/omarchy-shield.git](https://github.com/yourusername/omarchy-shield.git)
cd omarchy-shield
updpkgsums
makepkg -si
```

---

##  Setup & Quickshell Integration

### 1. Test the Widget Standalone
Verify both the unprivileged JSON telemetry stream and the floating UI bar immediately after installation:

```bash
# Verify JSON telemetry output (runs unprivileged, no password prompt)
omarchy-shield-ctl status

# Launch standalone floating bar window
quickshell -p /usr/share/quickshell/omarchy-shield/shell.qml
```

### 2. Embed into Your Omarchy Quickshell Bar
Open your main Omarchy Quickshell configuration (typically `~/.config/quickshell/shell.qml` or your top bar layout file), import the module directory, and place `ShieldWidget {}` inside your `RowLayout`:

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import "/usr/share/quickshell/omarchy-shield"

PanelWindow {
    // ... your existing bar configuration ...
    RowLayout {
        // Drop the security pill alongside your system tray / clock
        ShieldWidget {}
    }
}
```

### 3. (Recommended) Enable Boot-Level Kernel Lockdown in Limine
While `omarchy-shield` controls runtime kernel parameters dynamically, you can pair it with boot-time **Kernel Lockdown (`integrity`)** and **Heap Memory Zeroing** in `/etc/default/limine`:

```bash
# Append to /etc/default/limine:
KERNEL_CMDLINE[default]+="lsm=landlock,lockdown,yama,integrity,apparmor,bpf lockdown=integrity init_on_alloc=1"

# Regenerate the Omarchy Unified Kernel Image (UKI):
sudo limine-update
```

---

##  CLI & Hyprland Keybind Usage

You can also trigger `omarchy-shield-ctl` directly from the terminal or bind modes to keys in `~/.config/hypr/hyprland.conf`:

```bash
# Print live JSON telemetry (unprivileged)
omarchy-shield-ctl status

# Switch to Public Lockdown mode
omarchy-shield-ctl apply public 2 0 0

# Switch to Daily Workstation mode
omarchy-shield-ctl apply daily 1 0 0

# Switch to Lab & Gaming mode with a 90-minute auto-revert lease and OpenOCD/MQTT ports open
omarchy-shield-ctl apply lab 1 90 1

# Immediately revoke cached sudo and kill passwordless AI sudo rules
omarchy-shield-ctl revoke-sudo
```

Example Hyprland keybinds (`~/.config/hypr/hyprland.conf`):

```ini
bind = SUPER SHIFT, S, exec, omarchy-shield-ctl apply public 2 0 0
bind = SUPER SHIFT, L, exec, omarchy-shield-ctl apply lab 1 60 0
```

---

##  Uninstallation

Because all files are tracked by `pacman`, removing the package cleanly deletes the binary, Polkit policy, QML assets, and transient `/run/omarchy-shield.*` state files:

```bash
sudo pacman -Rns omarchy-shield
```

---

##  License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for details.
