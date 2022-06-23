#!/usr/bin/env bash

set -e

if [ -z "$1" ]
then
    echo "$0 [model]" >&2
    exit 1
fi
MODEL="$1"

make -C firmware distclean
make -C firmware "system76/${MODEL}:default:production"

#TODO: Should --dirty be used?
REVISION="$(grep QMK_VERSION firmware/quantum/version.h | cut -d '"' -f2)"
echo "REVISION: ${REVISION}"

DATE="$(grep QMK_BUILDDATE firmware/quantum/version.h | cut -d '"' -f2 | cut -d '-' -f1,2,3)"
echo "DATE: ${DATE}"

NAME="${MODEL}_${REVISION}"
echo "NAME: ${NAME}"

BUILD="build/production/${NAME}"
echo "BUILD: ${BUILD}"

rm -rf "${BUILD}"
mkdir -pv "${BUILD}"

cp "firmware/system76_${MODEL}_default_production.hex" "${BUILD}/${NAME}.hex"
avr-objcopy -I ihex -O binary "${BUILD}/${NAME}.hex" "${BUILD}/${NAME}.bin"
