#!/bin/bash

io_sizes=(4k 16k 64k 256k 1m 4m 16m)
dtypes=("nvme")
clients=(1 4 8 12 16 20 24 28 32 36 40)

# 1. test the effects of io_sizes, dtypes and client scaling
# 1.1 buffered_io
for procs in ${clients[@]}
do
    for dtype in ${dtypes[@]}
    do
        for io_size in ${io_sizes[@]}
        do
           ./run_ior.sh ${dtype} ${io_size} 1 ${procs}
        done
    done
done

# 1.2 direct_io
for procs in ${clients[@]}
do
    for dtype in ${dtypes[@]}
    do
        for io_size in ${io_sizes[@]}
        do
           ./run_ior.sh ${dtype} ${io_size} 0 ${procs}
        done
    done
done