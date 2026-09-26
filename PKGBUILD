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
    "LICENSE"
)
sha256sums=(
    'f29d37209c269ced0f6875a5aae3a397d9e9afb43d49f7339fbb67e2c2ab919b'
    'cca91031c3a8191189939497dc0f36bb6905f6436178da8a705528f8a520b5e1'
    '8eaeb09a4bc18b39ec9d8d944b13d1e01b12c9042bf15bfb7e4fcaaaedbb6df1'
    '839e1d76aa962978bbd7f7acaffd12eff89dd5431f115281e18e0b60e2021d45'
    'aa6321a7ff0ad568eafea7fe6492a707fdc29c0d703b495d960832715f3637ee'
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

    install -Dm644 "${srcdir}/LICENSE" \
        "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
