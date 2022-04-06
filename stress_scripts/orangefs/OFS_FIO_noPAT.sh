#!/bin/bash
# global variables
GEN_HOST="/home/jye20/symbios/scripts/gen_hosts.sh"
OFS_MOUNT_DIR="/mnt/nvme/jye20/OFS1-mount"
OFS_BIN_DIR="/home/jye20/install/orangefs-2.9.8/bin/"
OFS_SCRIPT_DIR="/home/jye20/symbios/scripts/orangefs/"
RESULT_LOG_PATH="/home/jye20/symbios/syn_test/orangefs/log"
FIO_CONF_PATH="/home/jye20/symbios/syn_test/orangefs/fio_confs"
CLIENT_HOST_FILE="/home/jye20/symbios/syn_test/orangefs/client_host_file"
PAT_PATH="/home/jye20/symbios/syn_test/pat/collect/"
BENMARK_DIR="/home/jye20/symbios/syn_test/orangefs"

# server numbers are 4,8,12,16,20,24 respectively
SRV_NUMS=(8)
#SRV_NUMS=(4 24)
#workload_types=("read_heavy")
#workload_types=("write_light" "read_light" "write_heavy" "read_heavy")
workload_types=("write_light" "read_light")

srv_start_idx=1 #used for create pat nodes
clt_start_idx=1
c_type=server

# io_pattern: "seq", "rand"
io_pattern="seq"
if [ ${io_pattern} == "seq" ];
then
    FIO_CONF_PATH=${FIO_CONF_PATH}"_seq"
else
    FIO_CONF_PATH=${FIO_CONF_PATH}"_rand"
fi

start_orangefs(){
    # start OrangeFS
    cd ${OFS_SCRIPT_DIR}/jarvis-cd-orangefs/
    python3 jarvis.py --log-path=./log/jarvis-start.log orangefs start --config=config/orangefs_conf.ini
    cd -
}

stop_orangefs(){
    # stop OrangeFS
    cd ${OFS_SCRIPT_DIR}/jarvis-cd-orangefs/
    python3 jarvis.py --log-path=./log/jarvis-stop.log orangefs stop --config=config/orangefs_conf.ini
    cd -
}

clear_cache(){
    # clear client system cache
    #mpssh -f ${OFS_SCRIPT_DIR}/orangefs/client_lists 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    # clear server system cache
    #mpssh -f ${OFS_SCRIPT_DIR}/orangefs/server_lists 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    mpssh -f ${OFS_SCRIPT_DIR}/orangefs/client_lists "sudo fm" > /dev/null 2>&1
    mpssh -f ${OFS_SCRIPT_DIR}/orangefs/server_lists "sudo fm" > /dev/null 2>&1
}

#${GEN_HOST} ${c_type} 8 ${clt_start_idx} ${OFS_SCRIPT_DIR}/orangefs/client_lists
#cp ${OFS_SCRIPT_DIR}/orangefs/client_lists ${BENMARK_DIR}/client_host_file
${BENMARK_DIR}/fio-server.sh stop ${BENMARK_DIR}/client_host_file
${BENMARK_DIR}/fio-server.sh start ${BENMARK_DIR}/client_host_file
for num in ${SRV_NUMS[*]}
do
    #clear cache
    clear_cache
    # generate server host files
    ${GEN_HOST} server ${num} ${srv_start_idx} ${OFS_SCRIPT_DIR}/orangefs/server_lists
    # stop Orangefs
    stop_orangefs
    sleep 1
    # Start OrangeFS
    start_orangefs
    sleep 2

    for type in ${workload_types[*]}
    do
        #mpssh -f ${CLIENT_HOST_FILE} "${BENMARK_DIR}/create_data_file.sh 327680" 
        if [ ${type} == "write_light" ] || [ ${type} == "write_heavy" ];
        then
            echo "begin ${type} test"
            rm -f ${OFS_MOUNT_DIR}/*
            clear_cache
            fio --client=${CLIENT_HOST_FILE} ${FIO_CONF_PATH}/fio_${type}.fio --output-format=normal --output=${RESULT_LOG_PATH}/fio_${io_pattern}_${num}_${type}.log
        else
            for i in $(seq 1 2)
            do
                clear_cache
	            fio --client=${CLIENT_HOST_FILE} ${FIO_CONF_PATH}/fio_${type}.fio --output-format=normal --output=${RESULT_LOG_PATH}/fio_${io_pattern}_${num}_${type}_${i}.log
	        done
        fi
       
        sleep 2
        # clear file
        clear_cache
    done

    #stop orangefs
    sleep 2
    stop_orangefs
done

#stop fio server
${BENMARK_DIR}/fio-server.sh stop ${BENMARK_DIR}/client_host_file
