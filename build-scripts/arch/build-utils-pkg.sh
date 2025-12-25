#!/bin/bash

set -e
set -x

pkgver="0.3"
pkgname="led-ugreen-utils"

# Create build directory
mkdir -p $pkgname

# Copy source files into build directory
cp -r cli $pkgname/
cp -r scripts $pkgname/

cd $pkgname

# Create PKGBUILD for utilities package
cat <<'PKGBUILD_EOF' > PKGBUILD
# Maintainer: Yuhao Zhou <miskcoo@gmail.com>
pkgname=led-ugreen-utils
pkgver=0.3
pkgrel=1
pkgdesc="UGREEN NAS LED control utilities"
arch=('x86_64')
url="https://github.com/miskcoo/ugreen_leds_controller"
license=('GPL')
depends=('dmidecode' 'smartmontools' 'i2c-tools')
provides=('led-ugreen-utils')
conflicts=('led-ugreen-utils')

build() {
    # Compile the CLI tool
    cd "${startdir}/cli"
    make -j$(nproc)
    cd "${startdir}"

    # Compile the disk activities monitor
    g++ -std=c++17 -O2 "${startdir}/scripts/blink-disk.cpp" -o "${startdir}/ugreen-blink-disk"
    
    # Compile the disk standby monitor
    g++ -std=c++17 -O2 "${startdir}/scripts/check-standby.cpp" -o "${startdir}/ugreen-check-standby"
}

package() {
    # Install scripts
    install -dm755 "${pkgdir}/usr/bin"

    local script_files=(ugreen-probe-leds ugreen-netdevmon ugreen-diskiomon ugreen-power-led)
    for f in "${script_files[@]}"; do
        install -Dm755 "${startdir}/scripts/$f" "${pkgdir}/usr/bin/$f"
    done

    # Install compiled binaries
    install -Dm755 "${startdir}/cli/ugreen_leds_cli" "${pkgdir}/usr/bin/ugreen_leds_cli"
    install -Dm755 "${startdir}/ugreen-blink-disk" "${pkgdir}/usr/bin/ugreen-blink-disk"
    install -Dm755 "${startdir}/ugreen-check-standby" "${pkgdir}/usr/bin/ugreen-check-standby"

    # Install systemd services
    install -dm755 "${pkgdir}/usr/lib/systemd/system"
    install -Dm644 "${startdir}/scripts/systemd/"*.service "${pkgdir}/usr/lib/systemd/system/"

    # Install example config file
    install -Dm644 "${startdir}/scripts/ugreen-leds.conf" "${pkgdir}/etc/ugreen-leds.example.conf"
}
PKGBUILD_EOF

# Build the package (skip dependency checks)
makepkg -f --nodeps

# Move package to parent directory
mv *.pkg.tar.zst ..

cd ..
rm -rf $pkgname
