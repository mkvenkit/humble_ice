PROJ = vga_bram
PCF = vga_bram.pcf
FPGA_PKG = sg48
FPGA_TYPE = up5k
NEXTPNR = nextpnr-ice40 
ICEPACK = icepack
ICETIME = icetime
ICEPROG = iceprog

all: $(PROJ).bin

PROJ_SRC = top.v hvsync_generator.v bram_buffer.v pll.v

%.bin: %.asc
	$(ICEPACK) $< $@

%.json: $(PROJ_SRC)
	yosys -ql $(basename $@)-yosys.log -p \
	    'synth_ice40 -top $(basename $@) -json $@' $(PROJ_SRC) 

%.asc: %.json
	nextpnr-ice40 --${FPGA_TYPE} --package ${FPGA_PKG} --json $< --pcf ${PCF} --asc $@

%.rpt: %.asc
	$(ICETIME) -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	$(ICEPROG) -S $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEPROG) $<

sudo-prog-ram: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEPROG) -S $<
sim:
	iverilog -o tb.out -s tb testbench.v 
	vvp tb.out

sim-show:
	gtkwave testbench.vcd   
	
clean:
	rm -f *.json *.asc *.log *.bin log.txt out.txt *.vcd *.out

.SECONDARY:
.PHONY: all prog clean

# make > out.txt 2>&1   

