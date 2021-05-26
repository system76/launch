#!/usr/bin/env python3

# Values from AP61302
## VOUT reference voltage (0.6V)
VOUT_REF = 0.6
## Switching frequency (2.2 MHz)
FSW = 2.2e6

# Values from PCB
## USB voltage (5V)
VIN = 5.0
## Inductor value (2.2 uH)
L = 2.2e-6
## Output capacitor value (22 uF)
COUT = 22.0e-6
## Capacitor ESR (ESTIMATED 500 mOhm)
ESR = 500.0e-3
## Resistor 1 values (9.1 kOhm, 52.3 kOhm)
R1S = [9.1e3, 52.3e3]
## Resistor 2 value (10 kOhm)
R2 = 10.0e3

for R1 in R1S:
    VOUT = VOUT_REF + (VOUT_REF * R1) / R2
    DELTA_IL = (VOUT * (VIN - VOUT)) / (VIN * FSW * L)
    VOUT_RIPPLE = DELTA_IL * (ESR + 1.0 / (8.0 * FSW * COUT))
    print(
            "VOUT", VOUT,
            "DELTA_IL", DELTA_IL,
            "VOUT_RIPPLE", VOUT_RIPPLE
    )
