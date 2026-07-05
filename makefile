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

init: scripts/init.sh
	source scripts/init.sh

compile_cpu: **/*.vhd
	vhpcomp n_bit_full_adder.vhd
	vhpcomp n_bit_full_subtractor.vhd
	vhpcomp alu.vhd
	vhpcomp ram.vhd
	vhpcomp cpu/virtual_instruction_decoder.vhd
	vhpcomp cpu/control_unit.vhd
