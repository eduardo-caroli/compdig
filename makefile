SHELL := /bin/bash

all: compile_cpu

test: testbenches/*.vhd
	source scripts/init.sh
	source scripts/import_tests.sh
	echo TESTS IMPORTED
	-source scripts/compile_tests.sh
	-source scripts/test.sh
	echo TESTS RUN
	source scripts/clean_tests.sh
	echo TESTS CLEANED

test_cpu: composition_tb
	isimgui -view isim.wdb -tclbatch testbenches/commands.tcl

compile_cpu_test: testbenches/cpu_tb.vhd src/**/*.vhd
	vhpcomp testbenches/composition_tb.vhd
	fuse work.composition_tb -o composition_tb

init: scripts/init.sh
	source scripts/init.sh

compile_cpu: **/*.vhd
	vhpcomp src/ram/ram_pkg.vhd
	vhpcomp src/alu/n_bit_full_adder.vhd
	vhpcomp src/alu/n_bit_full_subtractor.vhd
	vhpcomp src/alu/alu.vhd
	vhpcomp src/ram/ram.vhd
	vhpcomp src/cpu/virtual_instruction_decoder.vhd
	vhpcomp src/cpu/control_unit.vhd
	vhpcomp src/composition.vhd
	rm fuse.xmsgs
