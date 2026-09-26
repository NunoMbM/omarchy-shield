# Maintainer: NunoMbM <https://github.com/NunoMbM>
pkgname=omarchy-shield
pkgver=1.0.1
pkgrel=1
pkgdesc="Context-aware security & hardware profile switcher for Omarchy and Quickshell"
arch=('any')
url="https://github.com/NunoMbM/omarchy-shield"
license=('MIT')
depends=(
    'bash'
    'coreutils'
    'iproute2'
    'libnotify'
    'polkit'
    'procps-ng'
    'quickshell'
    'systemd'
    'util-linux'
)
optdepends=(
    'ufw: for firewall port management and local MCU/dev port rules'
)
install="${pkgname}.install"
source=(
    "omarchy-shield-ctl"
    "org.omarchy.shield.policy"
    "ShieldWidget.qml"
    "shell.qml"
)
# Run 'updpkgsums' after saving to replace these with real SHA-256 hashes:
sha256sums=(
    'SKIP'
    'SKIP'
    'SKIP'
    'SKIP'
)

package() {
    install -Dm755 "${srcdir}/omarchy-shield-ctl" \
        "${pkgdir}/usr/bin/omarchy-shield-ctl"

    install -Dm644 "${srcdir}/org.omarchy.shield.policy" \
        "${pkgdir}/usr/share/polkit-1/actions/org.omarchy.shield.policy"

    install -Dm644 "${srcdir}/ShieldWidget.qml" \
        "${pkgdir}/usr/share/quickshell/omarchy-shield/ShieldWidget.qml"
    install -Dm644 "${srcdir}/shell.qml" \
        "${pkgdir}/usr/share/quickshell/omarchy-shield/shell.qml"

    if [[ -f "${startdir}/LICENSE" ]]; then
        install -Dm644 "${startdir}/LICENSE" \
            "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
    fi
}
pkgname=omarchy-shield
pkgver=1.0.0
pkgrel=1
pkgdesc="Context-aware security & hardware profile switcher for Omarchy and Quickshell"
arch=('any')
url="https://github.com/yourusername/omarchy-shield"
license=('MIT')
depends=(
    'bash'
    'polkit'
    'quickshell'
    'iproute2'
    'procps-ng'
    'coreutils'
    'util-linux'
)
optdepends=(
    'ufw: for firewall port management and local dev port rules'
    'mokutil: fallback verification for UEFI Secure Boot state'
    'libnotify: desktop notifications on profile changes'
)
install="${pkgname}.install"
source=(
    "bin/omarchy-shield-ctl::file://src/bin/omarchy-shield-ctl"
    "polkit/org.omarchy.shield.policy::file://src/polkit/org.omarchy.shield.policy"
    "qml/ShieldWidget.qml::file://src/qml/ShieldWidget.qml"
    "qml/shell.qml::file://src/qml/shell.qml"
)
sha256sums=(
    'SKIP'
    'SKIP'
    'SKIP'
    'SKIP'
)

package() {
    # 1. Install backend control binary
    install -Dm755 "${srcdir}/bin/omarchy-shield-ctl" \
        "${pkgdir}/usr/bin/omarchy-shield-ctl"

    # 2. Install Polkit elevation action
    install -Dm644 "${srcdir}/polkit/org.omarchy.shield.policy" \
        "${pkgdir}/usr/share/polkit-1/actions/org.omarchy.shield.policy"

    # 3. Install QML components to system share
    install -Dm644 "${srcdir}/qml/ShieldWidget.qml" \
        "${pkgdir}/usr/share/quickshell/omarchy-shield/ShieldWidget.qml"
    install -Dm644 "${srcdir}/qml/shell.qml" \
        "${pkgdir}/usr/share/quickshell/omarchy-shield/shell.qml"

    # 4. Install license if present in repository root
    if [[ -f "${startdir}/LICENSE" ]]; then
        install -Dm644 "${startdir}/LICENSE" \
            "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
    fi
}
