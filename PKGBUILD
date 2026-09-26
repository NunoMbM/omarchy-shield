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
    'b68bcd19ebdf3f78ab6cce69fac478f0e3e209d441df5da8ae5813618449e09c'
    'cca91031c3a8191189939497dc0f36bb6905f6436178da8a705528f8a520b5e1'
    '7cb1ff9917498ab8a8ce7b7697fa71474cec013f73b412f03dcdc4dedd04dd80'
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
