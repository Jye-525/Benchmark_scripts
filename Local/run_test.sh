#!/bin/bash

io_sizes=(4k 16k 64k 256k 1m 4m 16m)
dtypes=("hdd" "ssd" "nvme")
clients=(4 8 12 16 20 24 28 32 36 40)

# 1. test the effects of io_sizes and dtypes
# 1.1 buffered_io
for io_size in ${io_sizes[@]}
do
    for dtype in ${dtypes[@]}
    do
       ./run_ior.sh ${dtype} ${io_size} 1 1
    done
done

for io_size in ${io_sizes[@]}
do
    for dtype in ${dtypes[@]}
    do
       ./run_ior.sh ${dtype} ${io_size} 0 1
    done
done