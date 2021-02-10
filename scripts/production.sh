#!/usr/bin/env bash

set -e

make -C firmware system76/launch_1:default:production

#TODO: Should --dirty be used?
REVISION="$(grep QMK_VERSION firmware/quantum/version.h | cut -d '"' -f2)"
echo "REVISION: ${REVISION}"

DATE="$(grep QMK_BUILDDATE firmware/quantum/version.h | cut -d '"' -f2 | cut -d '-' -f1,2,3)"
echo "DATE: ${DATE}"

NAME="launch_${REVISION}"
echo "NAME: ${NAME}"

BUILD="build/production/${NAME}"
echo "BUILD: ${BUILD}"

rm -rf "${BUILD}"
mkdir -pv "${BUILD}"

cp "firmware/system76_launch_1_default_production.hex" "${BUILD}/${NAME}.hex"
avr-objcopy -I ihex -O binary "${BUILD}/${NAME}.hex" "${BUILD}/${NAME}.bin"
