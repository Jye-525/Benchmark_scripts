#!/bin/bash

if [ $# -ne 1 ];
then
    echo "Usage: ./create_data_file.sh <block_counts>"
    echo "Note: a block size is 32k. The file size is <block_counts> * 32k and it is in /tmp/datafile"
    exit
fi

var1=$1
#remove existing data file
sudo rm /tmp/datafile  &> /tmp/dd.log
# create a data file
dd if=/dev/zero of=/tmp/datafile count=${var1} bs=32768 &> /tmp/dd.log

