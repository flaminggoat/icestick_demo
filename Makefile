PROJ = demo

PIN_DEF = icestick.pcf
DEVICE = hx1k

DOCKER_CMD = docker run --rm -it -v /$(shell pwd)://wrk -w //wrk
ICEPACK = $(DOCKER_CMD) ghdl/synth:icestorm icepack
NEXTPNR = $(DOCKER_CMD) ghdl/synth:nextpnr nextpnr-ice40
YOSYS = $(DOCKER_CMD) ghdl/synth:beta yosys

all: $(PROJ).bin

%.json: demo.vhdl uart/source/uart.vhd %.vhdl
	$(YOSYS) -m ghdl -p 'ghdl $^ -e demo; synth_ice40 -json $@'

%.asc: %.json
	$(NEXTPNR) --package $(DEVICE) --pcf $(PIN_DEF) --json $< --asc $@

%.bin: %.asc
	$(ICEPACK) $< $@

prog: $(PROJ).bin
	iceprog $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin

.SECONDARY:

.PHONY: all prog clean
