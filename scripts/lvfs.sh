#!/usr/bin/env bash

set -e

if [ -z "$1" ]
then
    echo "$0 [model] [description]" >&2
    exit 1
fi
MODEL="$1"

if [ -z "$2" ]
then
    echo "$0 [model] [description]" >&2
    exit 1
fi
DESCRIPTION="$2"

BOOTLOADER_VID="03EB" # Atmel
RUNTIME_VID="3384" # System76
case "${MODEL}" in
    "launch_1")
        BOOTLOADER_PID="2FF4" # ATMEGA32U4
        RUNTIME_PID="0001"
        RUNTIME_REV="0001"
        ;;
    "launch_2")
        BOOTLOADER_PID="2FF9" # AT90USB646
        RUNTIME_PID="0006"
        RUNTIME_REV="0001"
        ;;
    "launch_heavy_1")
        BOOTLOADER_PID="2FF9" # AT90USB646
        RUNTIME_PID="0007"
        RUNTIME_REV="0001"
        ;;
    "launch_lite_1")
        BOOTLOADER_PID="2FF9" # AT90USB646
        RUNTIME_PID="0005"
        RUNTIME_REV="0001"
        ;;
    *)
        echo "$0: unknown model '${MODEL}'" >&2
        exit 1
        ;;
esac

echo "MODEL: ${MODEL}"
echo "DESCRIPTION: ${DESCRIPTION}"

BOOTLOADER_ID="USB\\VID_${BOOTLOADER_VID}&PID_${BOOTLOADER_PID}"
echo "BOOTLOADER_ID: ${BOOTLOADER_ID}"

BOOTLOADER_UUID="$(appstream-util generate-guid "${BOOTLOADER_ID}")"
echo "BOOTLOADER_UUID: ${BOOTLOADER_UUID}"

RUNTIME_ID="USB\\VID_${RUNTIME_VID}&PID_${RUNTIME_PID}&REV_${RUNTIME_REV}"
echo "RUNTIME_ID: ${RUNTIME_ID}"

RUNTIME_UUID="$(appstream-util generate-guid "${RUNTIME_ID}")"
echo "RUNTIME_UUID: ${RUNTIME_UUID}"

make -C firmware distclean
make -C firmware "system76/${MODEL}:default"

#TODO: Should --dirty be used?
REVISION="$(grep QMK_VERSION firmware/quantum/version.h | cut -d '"' -f2)"
echo "REVISION: ${REVISION}"

DATE="$(grep QMK_BUILDDATE firmware/quantum/version.h | cut -d '"' -f2 | cut -d '-' -f1,2,3)"
echo "DATE: ${DATE}"

NAME="${MODEL}_${REVISION}"
echo "NAME: ${NAME}"

SOURCE="https://github.com/system76/launch"
echo "SOURCE: ${SOURCE}"

BUILD="build/lvfs/${NAME}"
echo "BUILD: ${BUILD}"

rm -rf "${BUILD}"
mkdir -pv "${BUILD}"

cp "firmware/.build/system76_${MODEL}_default.hex" "${BUILD}/firmware.hex"
avr-objcopy -I ihex -O binary "${BUILD}/firmware.hex" "${BUILD}/firmware.bin"
./scripts/add_dfu_header.py \
    --bin "${BUILD}/firmware.bin" \
    --dfu "${BUILD}/firmware.dfu" \
    --vid "${RUNTIME_VID}" \
    --pid "${RUNTIME_PID}" \
    --rev "${RUNTIME_REV}"

rm "${BUILD}/firmware.hex" "${BUILD}/firmware.bin"

echo "writing '${BUILD}/firmware.metainfo.xml'"
cat > "${BUILD}/firmware.metainfo.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright 2022 System76 <info@system76.com> -->
<component type="firmware">
  <id>com.system76.${MODEL}.firmware</id>
  <name>Launch Configurable Keyboard</name>
  <summary>System76 Launch Configurable Keyboard Firmware</summary>
  <description>
    <p>
      The System76 Launch Configurable Keyboard firmware is based on QMK and
      provides a USB HID keyboard implementation with keyboard remapping and
      RGB LED functionality
    </p>
  </description>
  <provides>
    <!-- ${RUNTIME_ID} -->
    <firmware type="flashed">${RUNTIME_UUID}</firmware>
  </provides>
  <url type="homepage">https://github.com/system76/launch</url>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>GPL-2.0+</project_license>
  <developer_name>System76</developer_name>
  <releases>
    <release urgency="high" version="${REVISION}" date="${DATE}" install_duration="15">
      <checksum filename="firmware.dfu" target="content"/>
      <url type="source">${SOURCE}</url>
      <description>
        <p>${DESCRIPTION}</p>
      </description>
    </release>
  </releases>
  <requires>
    <id compare="ge" version="1.9.5">org.freedesktop.fwupd</id>
  </requires>
  <categories>
    <category>X-Device</category>
  </categories>
  <keywords>
    <keyword>dfu</keyword>
  </keywords>
  <custom>
    <value key="LVFS::UpdateProtocol">org.usb.dfu</value>
    <value key="LVFS::VersionFormat">plain</value>
  </custom>
</component>
EOF

gcab \
    --verbose \
    --create \
    --nopath \
    "${BUILD}.cab" \
    "${BUILD}/"*

echo "created '${BUILD}.cab'"
