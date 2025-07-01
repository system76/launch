# System76 Launch Configurable Keyboard

The System76 Launch Configurable Keyboard is designed to provide the ultimate
user controlled keyboard experience, with open source mechanical and electrical
design, open source firmware and associated software, and a large number of
user configuration opportunities. It is registered open source hardware with
[OSHWA UID US001062](https://certification.oshwa.org/us001062.html).

- [Mechanical Design](#mechanical-design)
- [Electrical Design](#electrical-design)
- [Firmware and Software](#firmware-and-software)

## Mechanical Design

![Chassis Image](./chassis/launch/launch-chassis.png)

### Open Source Chassis

The Launch chassis is licensed CC-BY-SA-4.0 and can be viewed in the
[chassis](./chassis/) folder using [FreeCAD](https://www.freecad.org).

### Milled Aluminum

The chassis is milled from two solid blocks of aluminum and powder coated to
provide excellent fit and finish. Each pocket, port, and hole is designed and
precisely machined so that swapping switches and plugging in cables is easy and
secure for the user.

### Detachable Lift Bar

The included lift bar can be magnetically secured to add 15 degrees of angle to
your keyboard for ergonomics.

### Innovative Layout

The layout is designed to provide a large number of remapping opportunities.
The default layout can be viewed
[here](http://www.keyboard-layout-editor.com/#/gists/8ec5e9026d616ebad6b2c7e9d943e7c0),
and the extra keys included can be viewed
[here](http://www.keyboard-layout-editor.com/#/gists/a3ad8710b27f78fd938077b2bf6d3ef5).

### Swappable Keycaps

The keycaps are PBT material with a dye sublimation legend and XDA profile to
provide excellent feel and lifespan. Extras are provided for common replacements
and color preference. An included keycap puller can be used to move and replace
the keycaps.

### Swappable Switches

The switches are mounted in sockets that support any RGB switch with an MX
compatible footprint. Examples are the Cherry MX RGB switches and the Kailh
BOX switches. Switches can be removed easily at any time with the included
switch puller.

## Electrical Design

![PCB Image](./pcb/launch-pcb.png)

### Open Source PCB

The Launch PCB is licensed GPLv3 and can be viewed in the
[pcb](./pcb/) folder using [KiCad](https://kicad.org/).

### Integrated Dock

Launch connects to a computer using the included USB-C to USB-C cable or USB-C
to USB-A cable. It supports USB 3.2 Gen 2 with speeds up to 10 Gbps with either
cable, provided the computer supports these speeds. It provides 2 USB-C and 2
USB-A connectors that also support USB 3.2 Gen 2, with the 10 Gbps bandwidth
shared between them on demand.

### Independent RGB Lighting

Each switch has an RGB LED that is independently controlled by firmware. This
allows for a number of RGB LED patterns to be selected.

### N-Key Rollover

The keyboard matrix uses diodes on all intersections, providing full independent
scanning of each key position.

## Firmware and Software

### Open Source Firmware

The Launch firmware is based on [QMK](https://github.com/system76/qmk_firmware),
licensed GPLv2, and the latest version is linked in the `firmware` submodule.

### Open Source Software

Projects that integrate with Launch are open source software, such as the
[System76 Keyboard Configurator](https://github.com/pop-os/keyboard-configurator),
licensed GPLv3, and [fwupd](https://github.com/fwupd/fwupd/), licensed LGPLv2.1.

### Easy Remapping

The keyboard can be remapped at runtime using the
[System76 Keyboard Configurator](https://github.com/pop-os/keyboard-configurator).
This utility runs on Linux, Mac OS, and Windows.

### Firmware Updates

Firmware updates are supported through the
[fwupd](https://github.com/fwupd/fwupd/) project, and are distributed using the
related Linux Vendor Firmware Service. Settings are stored on EEPROM and are
maintained through firmware updates.
