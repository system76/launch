#!/usr/bin/env bash

set -e

####################
##     CONFIG     ##
####################

# xy of top left led (from the launch PCB, not heavy)
# Usually the first LED in the CSV
min_x=31.0
min_y=39.95

# Distance between left edge of the launch PCB and the left edge of the heavy PCB
heavy_offset=308.75

# Led names in sequential order. (See kicad_sch)
LEDS=(
	LM4 LL4 LK4 LJ4 LI4 LH4 LG4 LF4 LE4 LD4
	LC4 LB4 LA4 LA5 LB5 LC5 LD5 LE5 LG5 LH5
	LI5 LJ5 LK5 LL5 LM5 LO3 LM3 LL3 LK3 LJ3
	LI3 LH3 LG3 LF3 LE3 LD3 LC3 LB3 LA3 LA2
	LB2 LC2 LD2 LE2 LF2 LG2 LH2 LI2 LJ2 LK2
	LL2 LM2 LN2 LO2 LO1 LN1 LM1 LL1 LK1 LJ1
	LI1 LH1 LG1 LF1 LE1 LD1 LC1 LB1 LA1 LA0
	LB0 LC0 LD0 LE0 LF0 LG0 LH0 LI0 LJ0 LK0
	LL0 LM0 LN0 LO0
)

HEAVY_LEDS=(
	LD4 LC5 LA5 LA4 LB4 LC4 LC3 LB3 LA3 LA2
	LB2 LC2 LD2 LD1 LC1 LB1 LA1 LA0 LB0 LC0
	LD0
)

####################
##   End Config   ##
####################

if [ ! -e pcb/gerber/launch-top-pos.csv ]; then
	echo "File 'pcb/gerber/launch-top-pos.csv' does not exist."
	echo "create it by opening pcb/launch-kicad_pro in Kicad."
	echo "Then open launch.kicad_pcb:"
	echo "    File -> Fabrication Outputs -> Component Placement (.pos)"
	echo "    Then change the export type to '.csv' and click 'Generate Position File'"
	exit 1
fi

if [ ! -e pcb-heavy/gerber/launch-heavy-top-pos.csv ]; then
	echo "File 'pcb/gerber/launch-heavy-top-pos.csv' does not exist."
	echo "create it by opening pcb/launch-heavy-kicad_pro in Kicad."
	echo "Then open launch-heavy.kicad_pcb:"
	echo "    File -> Fabrication Outputs -> Component Placement (.pos)"
	echo "    Then change the export type to '.csv' and click 'Generate Position File'"
	exit 1
fi

#heavy_offset=$(echo "$heavy_offset - $min_x" | bc -lq)
heavy_offset=$(echo "$heavy_offset" | bc -lq)

# create hash map of led name to [x,y] positions
declare -A matrix_x
declare -A matrix_y
for led in "${LEDS[@]}"; do
	pos=($(grep "^\"${led}\"" pcb/gerber/launch-top-pos.csv | cut -d ',' -f4,5 | sed 's/,/ /g'))
	matrix_x["$led"]=$(echo "${pos[0]} + $min_x" | bc -lq)
	matrix_y["$led"]=$(echo "${pos[1]} * -1 - $min_y" | bc -lq)
done

for led in "${HEAVY_LEDS[@]}"; do
	pos=($(grep "^\"${led}\"" pcb-heavy/gerber/launch-heavy-top-pos.csv | cut -d ',' -f4,5 | sed 's/,/ /g'))
	matrix_x["$led-heavy"]=$(echo "${pos[0]} + $heavy_offset + $min_x" | bc -lq)
	matrix_y["$led-heavy"]=$(echo "${pos[1]} * -1 - $min_y" | bc -lq)
done

# led names are reused on both PCBs, this is to avoid that conflict,
# It's the same reason why we have `["$led-heavy"]` above
for ((i=0; i<${#HEAVY_LEDS[@]}; i++)); do
	HEAVY_LEDS[$i]="${HEAVY_LEDS[$i]}-heavy"
done


# get max x coordinate
first_led=${LEDS[0]}
max_x=${matrix_x[$first_led]}
for led in "${!matrix_x[@]}"; do
	x=${matrix_x[$led]}
	if [[ 1 == $(echo "$x > $max_x" | bc -lq) ]]; then
		max_x=$x
	fi
done

# get max y coordinate
max_y=${matrix_y[$first_led]}
for led in "${!matrix_y[@]}"; do
	y=${matrix_y[$led]}
	if [[ 1 == $(echo "$y > $max_y" | bc -lq) ]]; then
		max_y=$y
	fi
done

# We need to scale the kicad dimensions to the maximum values QMK accepts
# 224 for width, 64 for height
shrink_x=$(echo "224 / $max_x" | bc -lq)
shrink_y=$(echo "64 / $max_y" | bc -lq)

# multiply each value by scale value and print as a table
row=00
current=0
last=$((${#LEDS[@]}+${#HEAVY_LEDS[@]}))
printf "The following LED index to physical position matrix can be placed in:\nhttps://github.com/system76/qmk_firmware/blob/master/keyboards/system76/launch_heavy_1/launch_heavy_1.c\n"
for led in "${LEDS[@]}" "${HEAVY_LEDS[@]}"; do
	if [ $(( $current % 10 )) -eq 0 ]; then
		if [ $row -ge 100 ]; then
			printf "\n/* $row */ "
		else
			printf "\n/* 0$row */ "
		fi
		row=$(($row+10))
	fi
	current=$(($current+1))

	x=$(echo "${matrix_x[$led]} * $shrink_x" | bc -lq)
	y=$(echo "${matrix_y[$led]} * $shrink_x" | bc -lq)

	if [ $current -eq $last ]; then
		printf "{%.00f, %.00f}\n" $x $y
	else
		printf "{%.00f, %.00f}, " $x $y
	fi
done
