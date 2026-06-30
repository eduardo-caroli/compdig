SHELL := /bin/bash

all: test

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
