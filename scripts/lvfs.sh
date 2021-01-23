#!/usr/bin/env bash

set -e

BOOTLOADER_VID="03EB"
BOOTLOADER_PID="2FF4"
BOOTLOADER_ID="USB\\VID_${BOOTLOADER_VID}&PID_${BOOTLOADER_PID}"
echo "BOOTLOADER_ID: ${BOOTLOADER_ID}"

BOOTLOADER_UUID="$(appstream-util generate-guid "${BOOTLOADER_ID}")"
echo "BOOTLOADER_UUID: ${BOOTLOADER_UUID}"

RUNTIME_VID="3384"
RUNTIME_PID="0001"
RUNTIME_REV="0001"
RUNTIME_ID="USB\\VID_${RUNTIME_VID}&PID_${RUNTIME_PID}&REV_${RUNTIME_REV}"
echo "RUNTIME_ID: ${RUNTIME_ID}"

RUNTIME_UUID="$(appstream-util generate-guid "${RUNTIME_ID}")"
echo "RUNTIME_UUID: ${RUNTIME_UUID}"

make -C qmk_firmware system76/launch_beta_1:default

#TODO: Should --dirty be used?
REVISION="$(grep QMK_VERSION qmk_firmware/quantum/version.h | cut -d '"' -f2)"
echo "REVISION: ${REVISION}"

DATE="$(grep QMK_BUILDDATE qmk_firmware/quantum/version.h | cut -d '"' -f2)"
echo "DATE: ${DATE}"

if [ -z "$1" ]
then
    echo "$0 [description]" >&2
    exit 1
fi
DESCRIPTION="$1"
echo "DESCRIPTION: ${DESCRIPTION}"

NAME="launch_${REVISION}"
echo "NAME: ${NAME}"

SOURCE="https://github.com/system76/launch/releases/tag/${REVISION}"
echo "SOURCE: ${SOURCE}"

BUILD="build/lvfs/${NAME}"
echo "BUILD: ${BUILD}"

rm -rf "${BUILD}"
mkdir -pv "${BUILD}"

cp "qmk_firmware/.build/system76_launch_beta_1_default.hex" "${BUILD}/firmware.hex"
avr-objcopy -I ihex -O binary "${BUILD}/firmware.hex" "${BUILD}/firmware.bin"
./scripts/add_dfu_header.py \
    --bin "${BUILD}/firmware.bin" \
    --dfu "${BUILD}/firmware.dfu" \
    --vid "${RUNTIME_VID}" \
    --pid "${RUNTIME_PID}" \
    --rev "${RUNTIME_REV}"

echo "writing '${BUILD}/firmware.metainfo.xml'"
cat > "${BUILD}/firmware.metainfo.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright 2019 System76 <info@system76.com> -->
<component type="firmware">
  <id>com.system76.launch_1.firmware</id>
  <name>System76 Launch</name>
  <summary>Firmware for the System76 Launch</summary>
  <description>
    <p>
      System76 Launch Configurable Keyboard Firmware
    </p>
  </description>
  <provides>
    <!-- ${BOOTLOADER_ID} -->
    <firmware type="flashed">${BOOTLOADER_UUID}</firmware>
    <!-- ${RUNTIME_ID} -->
    <firmware type="flashed">${RUNTIME_UUID}</firmware>
  </provides>
  <url type="homepage">https://github.com/system76/launch</url>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>GPL-3.0+</project_license>
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
  <categories>
    <category>X-Device</category>
  </categories>
  <keywords>
    <keyword>dfu</keyword>
  </keywords>
  <custom>
    <value key="LVFS::UpdateProtocol">org.usb.dfu</value>
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
