#!/bin/bash

set -x

if [[ ! -d ./build ]]; then
    mkdir build
fi

docker build --platform linux/amd64 --tag archlinux-build .
docker run \
    --platform linux/amd64 \
    --rm \
    --mount type=bind,source=$(pwd)/build,target=/build \
    --mount type=bind,source=$(pwd),target=/build-scripts \
    archlinux-build \
    bash -c "cd /build && bash /build-scripts/build.sh $1"
