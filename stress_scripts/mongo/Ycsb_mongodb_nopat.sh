# global variables
GEN_HOST="/home/jye20/symbios/scripts/gen_hosts.sh"
MONGO_SCRIPT_DIR="/home/jye20/symbios/scripts/mongo/"
RESULT_LOG_PATH="/tmp/mongo_test_log"
CLIENT_HOST_FILE="/home/jye20/symbios/syn_test/mongo/client_host_file"
PAT_PATH="/home/jye20/symbios/syn_test/pat/collect/"
YCSB_PATH="/home/jye20/symbios/ycsb-0.17.0/bin"

#redis workloads
WORKLOADS_DIR="/home/jye20/symbios/syn_test/mongo/workloads/"
BENCHMARK_DIR="/home/jye20/symbios/syn_test/mongo/"

# server numbers are 4,8,12,16,20,24 respectively
#SRV_NUMS=(4 8 12 16 20 24)
SRV_NUMS=(4)
workload_types=("write_light" "read_light")
#workload_types=("write_heavy" "read_heavy")
#workload_types=("read_light")

srv_start_idx=12 #used for create pat nodes

load_type="light"
maxtime=60
mode="sync"
route_port=27017

start_mongo_cluster(){
    # start mongo cluster
    ${MONGO_SCRIPT_DIR}/start_mongo_cluster.sh
}

stop_mongo_cluster(){
    # stop mongo cluster
    ${MONGO_SCRIPT_DIR}/stop_mongo_cluster.sh
    # clean mongo cluster
    ${MONGO_SCRIPT_DIR}/clean.sh
}

clear_cache(){
    # clear client system cache
    #mpssh -f ${CLIENT_HOST_FILE} 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    # clear server system cache
    #mpssh -f ${MONGO_SCRIPT_DIR}/shard_servers 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    mpssh -f ${CLIENT_HOST_FILE} "sudo fm" > /dev/null 2>&1
    mpssh -f ${MONGO_SCRIPT_DIR}/shard_servers "sudo fm" > /dev/null 2>&1
}

get_all_nodes(){
    node_num=$1
    if [ ${srv_start_idx} -lt 10 ];
    then
        all_nodes="ares-comp-0${srv_start_idx}-40g:22 "
    else
        all_nodes="ares-comp-${srv_start_idx}-40g:22 "
    fi
    start_idx=$(expr $srv_start_idx + 1)
    end_idx=$(expr $srv_start_idx + $node_num)
    for ((i=${start_idx};i<${end_idx};i++))
    do
        if [ ${i} -lt 10 ];
        then
            all_nodes=${all_nodes}"ares-comp-0${i}-40g "
        else
            all_nodes=${all_nodes}"ares-comp-${i}-40g "
        fi
    done
    echo ${all_nodes}
}

get_router_servers(){
    route_srvs_str=""
    route_srvs=`cat ${MONGO_SCRIPT_DIR}/router_servers|awk '{print $1}'`
    for route_srv in ${route_srvs[@]}
    do
        route_srvs_str=${route_srvs_str}${route_srv}":"${route_port}","
    done
    # remove the last ','
    route_srvs_str=${route_srvs_str::-1}
    echo ${route_srvs_str}
}

load_data() {
    t_num=$1
    if [ ${mode} == "sync" ];
    then
        ${YCSB_PATH}/ycsb load mongodb -threads ${t_num} -P ${WORKLOADS_DIR}/workload_load_${load_type} -P ${BENCHMARK_DIR}/mongodb.properties > ${RESULT_LOG_PATH}/load_${mode}_${num}_${load_type}_result.log
    else
        ${YCSB_PATH}/ycsb load mongodb-async -threads ${t_num} -P ${WORKLOADS_DIR}/workload_load_${load_type} -P ${BENCHMARK_DIR}/mongodb.properties > ${RESULT_LOG_PATH}/load_${mode}_${num}_${load_type}_result.log
    fi
}


mpssh -f ${CLIENT_HOST_FILE} "mkdir -p ${RESULT_LOG_PATH}"
for num in ${SRV_NUMS[*]}
do
    # generate config server host files
    ${GEN_HOST} server 2 ${srv_start_idx} ${MONGO_SCRIPT_DIR}/conf_servers
    # generate shard server host files
    ${GEN_HOST} server ${num} ${srv_start_idx} ${MONGO_SCRIPT_DIR}/shard_servers
    # generate router server host files
    ${GEN_HOST} server ${num} ${srv_start_idx} ${MONGO_SCRIPT_DIR}/router_servers
    #clear cache
    clear_cache
    #stop mongo cluster
    stop_mongo_cluster
    #sleep 2s
    sleep 1
    #Start mongo cluster
    start_mongo_cluster
    sleep 2

    #load data into mongo_cluster
    route_srvs_str=$( get_router_servers )
    echo "mongodb.url=mongodb://${route_srvs_str}/ycsb?" > ${BENCHMARK_DIR}/mongodb.properties
    echo "mongodb.batchsize=100" >> ${BENCHMARK_DIR}/mongodb.properties
    echo "mongodb.maxconnections=100000" >> ${BENCHMARK_DIR}/mongodb.properties
    load_data 40
    sleep 2
    clear_cache

    # run the workload
    for type in ${workload_types[*]}
    do
        if [ ${mode} == "sync" ];
        then
            mpssh -f ${CLIENT_HOST_FILE} "${YCSB_PATH}/ycsb run mongodb -threads ${t_num} -P $WORKLOADS_DIR/workload_${load_type} -P ${BENCHMARK_DIR}/mongodb.properties -p maxexecutiontime=${maxtime} > ${RESULT_LOG_PATH}/mongo_${mode}_${num}_${load_type}.log"
        else
            mpssh -f ${CLIENT_HOST_FILE} "${YCSB_PATH}/ycsb run mongodb-async -threads ${t_num} -P $WORKLOADS_DIR/workload_${load_type} -P ${BENCHMARK_DIR}/mongodb.properties -p maxexecutiontime=${maxtime} > ${RESULT_LOG_PATH}/mongo_${mode}_${num}_${load_type}.log"
        fi
        sleep 2
        clear_cache
        sleep 3
    done

    #stop mongo cluster
    sleep 1
    stop_mongo_cluster
done
