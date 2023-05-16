# Chinese nine rings
## Overview
Chinese nine rings is a puzzle that is said to have originated in ancient China.
Nine metal rings are attached to the elongated body, and another elongated ring remove from the nine rings and attache again for play.
This project is an electronic simuration of this puzzle. By pressing the tact switch, you can turn on and off the LED as if you were passing the ring through or out.

## Circuit
It is simple, 9 LEDs and 9 tact switches are connected to baseline PIC16F57.
If you want to modify take care must not to exceed 50mA total current for each output port.

## BOM
PIC16F57, IC (28p) socket,
LED x 9,
tact switch x 10,
resistor 12k ohm x 10, 2.2k ohm x 9,
capacitor 0.1uF x 1,
resonator 4MHz x 1,
power connector,
printed cicuit board and other if you need...

## Programming
Build the project with MPLAB XC8 Assembler. You also need a programming tool like Microchip Pickit.

## To solve
Your mission is to turn on all LEDs, and then turn off all LEDs.
There are one or two correct switches on each step. Pressing the correct switch toggles the corresponding LED on/off state. Whether an LED can be turned on/off depends on the state of other LEDs. No random elements. Everything works as logical.

## Important point
Unfortunately if it doesn't work, suspect your soldering first, please.
