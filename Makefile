PROJ = demo

PIN_DEF = icestick.pcf
DEVICE = hx1k

TOP_LEVEL = demo
VHDL_FILES = demo.vhdl rom.vhdl uart/source/uart.vhd
VERILOG_FILES = pll.v

DOCKER_CMD = docker run --rm -it -v /$(shell pwd)://wrk -w //wrk
ICEPACK = $(DOCKER_CMD) ghdl/synth:icestorm icepack
NEXTPNR = $(DOCKER_CMD) ghdl/synth:nextpnr nextpnr-ice40
YOSYS = $(DOCKER_CMD) ghdl/synth:beta yosys

ifneq ($(VERILOG_FILES),)
MAYBE_READ_VERILOG = read_verilog $(VERILOG_FILES);
endif

all: $(PROJ).bin

%.json: $(VHDL_FILES) %.vhdl
	$(YOSYS) -m ghdl -p \
		"ghdl $^ -e $(TOP_LEVEL); \
		$(MAYBE_READ_VERILOG) \
		synth_ice40 -json $@"

%.asc: %.json
	$(NEXTPNR) --package $(DEVICE) --pcf $(PIN_DEF) --pcf-allow-unconstrained --json $< --asc $@

%.bin: %.asc
	$(ICEPACK) $< $@

prog: $(PROJ).bin
	iceprog $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin

.SECONDARY:

.PHONY: all prog clean
