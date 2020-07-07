# Icestorm VDHL IceStick Demo
Basic VHDL demo project using the opensource toolchain for the ICE40 FPGAs, involving ghdl-yosys-plugin, yosys, nextpnr and icestorm.
The Makefile uses docker containers to compile the project.

## Components
 * UART - Sends data from ROM when data is received.
 * ROM - Stores a small piece of text
 * PLL - The PLL is described in verilog and instantiated in VHDL. It is not necessary to use the PLL for this project, it is just instantiated to demonstrate its use.