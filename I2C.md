I2C addresses in this document include the R/W bit.

# USB Hub @ 0x5A

As I2C pullups are present on this board, the hub will wait for configuration before becoming active. The upstream superspeed mux should be set first.

# Type C Port Controllers (TCPC)
 - Register information is in PTN5110_AN2137.pdf rather than the data sheet.
 - The FRS pin is used as a GPIO to control the superspeed mux. See EXT_GPIO_CONFIG/CONTROL registers.
 - The interrupt pin is not wired due to lack of pins on the AVR. The TCPCs will need to be periodically polled. 
 - All support full USB PD communication, but this does not have to be used
 - Can source VCONN for active cables, electronic markers

## Upstream @ 0xA2
 - The CC_STATUS reigster can be read to determine connector orientation and available power.
 - A PD contract may allow more power than indicated in CC_STATUS, for example, a device that can source 2 A would report 1.5 A via CC_STATUS.
 - PTN5110DHQ which defaults to acting as a power sink.
 - Defaults should be OK except for GPIO setup on FRS.
## Downstream C Left @ 0xA4, Right @ 0xA0
 - PTN5110THQ which defaults to acting as a power source
 - The AVR will need to poll for cable connects and disconnects. tVbusOFF in the USB C spec is 650 ms which sets the maximum polling interval.
 - The SRC pin is used on the downstream ports to enable sourcing power. It may be required to switch the SRC pin to a GPIO so that sourcing power is only enabled after the superspeed mux is set properly.
 - It's probably best to only offer default power.
