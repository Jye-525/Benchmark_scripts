#!/bin/bash
# global variables
GEN_HOST="/home/cc/common/scripts/gen_hosts.sh"
OFS_SCRIPT_DIR="/home/cc/common/scripts/orangefs/"
RESULT_LOG_PATH="/home/cc/common/syn_test/orangefs/log"
IOR_BIN="/home/cc/common/ior-3.3.0/bin/ior"
IOR_CONF_PATH="/home/cc/common/syn_test/orangefs/ior_confs/"
PAT_PATH="/home/cc/common/syn_test/pat/collect/"
CLIENT_HOST_FILE="/home/cc/common/syn_test/orangefs/client_host_file"
# server numbers are 4,8,12,16,20,24 respectively
#SRV_NUMS=(4 8 12 16 20 24)
SRV_NUMS=(16 20 24)
#workload_types=("write_heavy" "read_heavy" "writeread_heavy" "write_light" "read_light" "writeread_light")
#workload_types=("write_light" "read_light" "write_heavy" "read_heavy")
workload_types=("write_light" "read_light")

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
    mpssh -f ${OFS_SCRIPT_DIR}/orangefs/client_lists 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    # clear server system cache
    mpssh -f ${OFS_SCRIPT_DIR}/orangefs/server_lists 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
}

get_pat_nodes(){
    node_nums=$1
    all_nodes="symbios-server-1:22 "
    for ((i=2;i<=${node_nums};i++))
    do
       all_nodes=${all_nodes}"symbios-server-${i} "
    done
    echo ${all_nodes}
}

for num in ${SRV_NUMS[*]}
do
    # generate server host files
    ${GEN_HOST} server ${num} ${OFS_SCRIPT_DIR}/orangefs/server_lists
    clear_cache
    # stop Orangefs
    stop_orangefs
    # sleep 2s
    sleep 2
    # Start OrangeFS
    start_orangefs
    sleep 2

    allnodes=$( get_pat_nodes ${num} )
    echo "pat all nodes are: ${allnodes}"    
    for type in ${workload_types[*]}
    do
        #cmd="mpirun -f ${CLIENT_HOST_FILE} -ppn 40 ${IOR_BIN} -w -f ${IOR_CONF_PATH}/ior_${type}.conf -o /home/cc/OFS1-mount/test -O summaryFile=${RESULT_LOG_PATH}/ior_${num}_${type}.log"
        # change PAT config
        #cd ${PAT_PATH}
        #sed -i "/^ALL_NODES: /cALL_NODES: ${allnodes}" config
        #sed -i "/^CMD_PATH: /cCMD_PATH: ${cmd}" config
        # running pat
        #./pat run ior_${num}_${type}        
        #mpirun -f ${CLIENT_HOST_FILE} -ppn 40 ${IOR_BIN} -w -f ${IOR_CONF_PATH}/ior_${type}.conf -o /home/cc/OFS1-mount/test -O summaryFile=${RESULT_LOG_PATH}/ior_${num}_${type}.log
        mpirun -f ${CLIENT_HOST_FILE} -ppn 40 ${IOR_BIN} -w -f ${IOR_CONF_PATH}/ior_${type}.conf -o /home/cc/OFS1-mount/test > ${RESULT_LOG_PATH}/ior_${num}_${type}.log
        sleep 5
        clear_cache
    done

    #stop orangefs
    sleep 2
    stop_orangefs
done
