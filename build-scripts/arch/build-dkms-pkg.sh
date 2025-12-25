#!/bin/bash

set -e
set -x

pkgver="0.3"
pkgname="led-ugreen-dkms"
drivername="led-ugreen"

# Create build directory
mkdir -p $pkgname

# Copy kmod source files into build directory
cp -r kmod $pkgname/

cd $pkgname

# Create PKGBUILD for DKMS package
cat <<'PKGBUILD_EOF' > PKGBUILD
# Maintainer: Yuhao Zhou <miskcoo@gmail.com>
pkgname=led-ugreen-dkms
pkgver=0.3
pkgrel=1
pkgdesc="UGREEN NAS LED driver (DKMS)"
arch=('x86_64')
url="https://github.com/miskcoo/ugreen_leds_controller"
license=('GPL')
depends=('dkms')
optdepends=(
    'linux-headers: for linux kernel'
    'linux-lts-headers: for linux-lts kernel'
    'linux-zen-headers: for linux-zen kernel'
    'linux-hardened-headers: for linux-hardened kernel'
)
provides=('led-ugreen-dkms')
conflicts=('led-ugreen-dkms')
install="${pkgname}.install"

package() {
    # Install DKMS source files
    install -dm755 "${pkgdir}/usr/src/${pkgname%-dkms}-${pkgver}"

    # Copy kernel module source files from startdir
    cp -r "${startdir}/kmod/"* "${pkgdir}/usr/src/${pkgname%-dkms}-${pkgver}/"
}
PKGBUILD_EOF

# Create install script for DKMS hooks
cat <<'INSTALL_EOF' > led-ugreen-dkms.install
post_install() {
    dkms add -m led-ugreen -v 0.3
    dkms build -m led-ugreen -v 0.3 && dkms install -m led-ugreen -v 0.3 || true
}

post_upgrade() {
    post_install
}

pre_remove() {
    dkms remove -m led-ugreen -v 0.3 --all || true
}
INSTALL_EOF

# Build the package (skip dependency checks)
makepkg -f --nodeps

# Move package to parent directory
mv *.pkg.tar.zst ..

cd ..
rm -rf $pkgname
