#!/usr/bin/env bash

set -e

if [ -z "$1" ]
then
    echo "$0 [description]" >&2
    exit 1
fi
DESCRIPTION="$1"
echo "DESCRIPTION: ${DESCRIPTION}"

BOOTLOADER_VID="03EB"
BOOTLOADER_PID="2FF9"
BOOTLOADER_ID="USB\\VID_${BOOTLOADER_VID}&PID_${BOOTLOADER_PID}"
echo "BOOTLOADER_ID: ${BOOTLOADER_ID}"

BOOTLOADER_UUID="$(appstream-util generate-guid "${BOOTLOADER_ID}")"
echo "BOOTLOADER_UUID: ${BOOTLOADER_UUID}"

RUNTIME_VID="3384"
RUNTIME_PID="0005"
RUNTIME_REV="0001"
RUNTIME_ID="USB\\VID_${RUNTIME_VID}&PID_${RUNTIME_PID}&REV_${RUNTIME_REV}"
echo "RUNTIME_ID: ${RUNTIME_ID}"

RUNTIME_UUID="$(appstream-util generate-guid "${RUNTIME_ID}")"
echo "RUNTIME_UUID: ${RUNTIME_UUID}"

make -C firmware clean
make -C firmware system76/launch_lite_1:default

#TODO: Should --dirty be used?
REVISION="$(grep QMK_VERSION firmware/quantum/version.h | cut -d '"' -f2)"
echo "REVISION: ${REVISION}"

DATE="$(grep QMK_BUILDDATE firmware/quantum/version.h | cut -d '"' -f2 | cut -d '-' -f1,2,3)"
echo "DATE: ${DATE}"

NAME="launch_lite_1_${REVISION}"
echo "NAME: ${NAME}"

SOURCE="https://github.com/system76/launch"
echo "SOURCE: ${SOURCE}"

BUILD="build/lvfs/${NAME}"
echo "BUILD: ${BUILD}"

rm -rf "${BUILD}"
mkdir -pv "${BUILD}"

cp "firmware/.build/system76_launch_lite_1_default.hex" "${BUILD}/firmware.hex"
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
<!-- Copyright 2021 System76 <info@system76.com> -->
<component type="firmware">
  <id>com.system76.launch_lite_1.firmware</id>
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
