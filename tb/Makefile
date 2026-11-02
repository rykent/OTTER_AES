# Makefile

# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
EXTRA_ARGS = -Wno-fatal --trace-structs

VERILOG_SOURCES += $(PWD)/../src/*.sv

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = OTTER_Wrapper

# MODULE is the basename of the Python test file
MODULE = benchmark

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
