#!/bin/bash

if [ $# -ne 4 ];
then
	echo "Usage: ./run_ior.sh <device_type> <blocksize> <buffered_io> <procs>"
	exit 1
fi

user=jye20
dtype=$1
bs=$2
buffered=$3
procs=$4

filesize=1G
loops=5
log_dir=./ior_log_14_procs

data_dir=/mnt/${dtype}/${user}/

clear_files() {
    rm -rf ${data_dir}/*
    sudo fm
}

run_buffer_ior() {
	#clear cache
    clear_files
    sudo fm
    sleep 1
    #write data
    time ior -a POSIX -t ${bs} -b ${filesize} -s 1 -w -i ${loops} -F -k -o ${data_dir}/ior_buff_data.dat > ${log_dir}/ior_buff_${procs}_${bs}_write_${dtype}.log
    sleep 2
    #read data
    time ior -a POSIX -t ${bs} -b ${filesize} -s 1 -r -i ${loops} -F -k -o ${data_dir}/ior_buff_data.dat > ${log_dir}/ior_buff_${procs}_${bs}_read_${dtype}.log

}

run_buffer_ior_procs() {
    clear_files
    sudo fm
    sleep 1
    #write data
    time mpirun -n ${procs} ior -a POSIX -t ${bs} -b ${filesize} -s 1 -w -i ${loops} -F -k -o ${data_dir}/ior_buff_data.dat > ${log_dir}/ior_buff_${procs}_${bs}_write_${dtype}.log
    sleep 2
    #read data
    time mpirun -n ${procs} ior -a POSIX -t ${bs} -b ${filesize} -s 1 -r -i ${loops} -F -k -o ${data_dir}/ior_buff_data.dat > ${log_dir}/ior_buff_${procs}_${bs}_read_${dtype}.log
}

run_direct_ior() {
	#clear cache
    clear_files
    sudo fm
    sleep 1
    # write data
    time ior -a POSIX --posix.odirect -t ${bs} -b ${filesize} -s 1 -w -i ${loops} -F -k -o ${data_dir}/ior_data.dat > ${log_dir}/ior_direct_${procs}_${bs}_write_${dtype}.log
    sleep 2
    sudo fm
    # read data
    time ior -a POSIX --posix.odirect -t ${bs} -b ${filesize} -s 1 -r -i ${loops} -F -k -o ${data_dir}/ior_data.dat > ${log_dir}/ior_direct_${procs}_${bs}_read_${dtype}.log
}

run_direct_ior_procs() {
	#clear cache
    clear_files
    sudo fm
    sleep 1
    # write data
    time mpirun -n ${procs} ior -a POSIX --posix.odirect -t ${bs} -b ${filesize} -s 1 -w -i ${loops} -F -k -m -o ${data_dir}/ior_data.dat > ${log_dir}/ior_direct_${procs}_${bs}_write_${dtype}.log
    sleep 2
    sudo fm
    # read data
    time mpirun -n ${procs} ior -a POSIX --posix.odirect -t ${bs} -b ${filesize} -s 1 -r -i ${loops} -F -k -m -o ${data_dir}/ior_data.dat > ${log_dir}/ior_direct_${procs}_${bs}_read_${dtype}.log
}

if [ ${buffered} -eq 1 ];
then
	if [ ${procs} -eq 1 ]; then run_buffer_ior; fi
	if [ ${procs} -gt 1 ]; then run_buffer_ior_procs; fi
fi

if [ ${buffered} -eq 0 ];
then
	if [ ${procs} -eq 1 ]; then run_direct_ior; fi
	if [ ${procs} -gt 1 ]; then run_direct_ior_procs; fi
fi