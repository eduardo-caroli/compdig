#!/bin/bash

for test in *_tb.vhd; do
    tb_name="${test%.vhd}"
    fuse "work.$tb_name" -o $tb_name
done
