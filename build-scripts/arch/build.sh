#!/bin/bash

set -x

# Clean up any previous build
rm -rf ugreen_leds_controller

git clone https://github.com/miskcoo/ugreen_leds_controller.git 
cd ugreen_leds_controller 

if [ ! -z $1 ]; then 
    git checkout $1
fi

bash /build-scripts/build-dkms-pkg.sh
bash /build-scripts/build-utils-pkg.sh
mv *.pkg.tar.zst ..
