# Version Pins PB4-PB7

These are only present on boards with the AT90USB646 microcontroller
(Lite, Launch 2).

Pin PE1 will be grounded if a numeric keypad is present.

| Version    | PB4  | PB5  | PB6  | PB7  |
|------------|------|------|------|------|
| Lite 1.0   | open | open | open | open |
| Launch 2.0 | GND  | open | open | open |

# Part Substitutions

#### USB7xx6 USB hub

Can use USB7206 or USB7006 any PCB, USB7216 on any PCB >= Launch
1.1. Note that USB7006 is only Gen 1 USB.

 - USB7206: original, do not install R18, R28 if using, Gen 2 (10 Gb/s)
 - USB7216: alternate, install R18, R28, Gen 2 (10 Gb/s), has built Type-C support for 1 port which we are not using to retain ability to use USB7206.
 - USB7006: alternate, do not install R18, R28 if using, Gen 1 (5 Gb/s)

#### PTN5111 Type-C port controller

NXP introduced the PTN5110NHQZ and discontinued all others in the
PTN5110 line. It defaults to a toggling dual role port, will need to
be configured by software for the downstream facing ports. The
upstream facing port should select the correct mode. No hardware
changes are required.

 - PTN5110THQ: original for downstream ports (U12, U13), defaults to sourcing power
 - PTN5110DHQ: original for upstream port (U11), defaults to sinking power
 - PTN5110NHQZ: replacement, defaults to dual role port, same part used all 3 locations

#### Buck converters

Changes were all due to availability problems. Each part only works
with the listed PCB revisions.

 - TI TLV62585PDRL: Launch 1.0, 1.1
 - Diodes Inc. AP3441LSHE-7B: Launch 1.2, 1.4
 - Diodes Inc. AP61302: Launch 1.3
 - Aerosemi M3406-ADJ: Launch Lite 1.0
 - Aerosemi MT3410LB: Launch 2.0