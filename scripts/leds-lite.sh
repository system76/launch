#!/usr/bin/env bash

set -e

LEDS=(
	LM4 LL4 LK4 LJ4 LI4 LH4 LG4 LF4 LE4 LD4
	LC4 LB4 LA4 LA5 LB5 LC5 LD5 LE5 LG5 LH5
	LI5 LJ5 LK5 LL5 LM5 LO3 LM3 LL3 LK3 LJ3
	LI3 LH3 LG3 LF3 LE3 LD3 LC3 LB3 LA3 LA2
	LB2 LC2 LD2 LE2 LF2 LG2 LH2 LI2 LJ2 LK2
	LL2 LM2 LN2 LO2 LO1 LN1 LM1 LL1 LK1 LJ1
	LI1 LH1 LG1 LF1 LE1 LD1 LC1 LB1 LA1 LO0
)

min_x=60
min_y=-73.95
scale_x=280.25
scale_y=76

printf "LED\tX\tY\tRX\tRY\tSX\tSY\tMX\tMY\n" >&2
for led in "${LEDS[@]}"
do
	pos=($(grep "^${led}" pcb-lite/gerber/launch-lite-top.pos | tr -s ' ' | cut -d ' ' -f4,5))
	x="${pos[0]}"
	y="${pos[1]}"
	rx=$(echo "$x - $min_x" | bc -lq)
	ry=$(echo "$min_y - $y" | bc -lq)
	sx=$(echo "$rx / $scale_x" | bc -lq)
	sy=$(echo "$ry / $scale_y" | bc -lq)
	mx=$(echo "224 * $sx" | bc -lq)
	my=$(echo "64 * $sy" | bc -lq)
	printf "%s\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\n" $led $x $y $rx $ry $sx $sy $mx $my >&2
	printf "{%.00f, %.00f},\n" $mx $my
done
