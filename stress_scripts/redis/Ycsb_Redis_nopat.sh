# global variables
GEN_HOST="/home/jye20/symbios/scripts/gen_hosts.sh"
REDIS_SCRIPT_DIR="/home/jye20/symbios/scripts/redis/"
RESULT_LOG_PATH="/tmp/redis_test_log"
CLIENT_HOST_FILE="/home/jye20/symbios/syn_test/redis/client_host_file"
PAT_PATH="/home/jye20/symbios/syn_test/pat/collect/"
YCSB_PATH="/home/jye20/symbios/ycsb-0.17.0/bin"

#redis workloads
WORKLOADS_DIR="/home/jye20/symbios/syn_test/redis/workloads/"
BENCHMARK_DIR="/home/jye20/symbios/syn_test/redis/"

# server numbers are 4,8,12,16,20,24 respectively
#SRV_NUMS=(4 8 12 16 20 24)
SRV_NUMS=(4)
#workload_types=("write_light" "read_light" "write_heavy" "read_heavy")
workload_types=("write_light" "read_light")
#workload_types=("write_heavy" "read_heavy")

srv_start_idx=12 #used for create pat nodes

load_type="light"
maxtime=120

start_redis_cluster(){
    # start redis cluster
    ${REDIS_SCRIPT_DIR}/start_redis_cluster.sh env_conf_c1.sh
}

stop_redis_cluster(){
    # stop redis cluster
    ${REDIS_SCRIPT_DIR}/stop_redis_cluster.sh env_conf_c1.sh
    # clean redis cluster
    ${REDIS_SCRIPT_DIR}/clean.sh env_conf_c1.sh
}

clear_cache(){
    # clear client system cache
    #mpssh -f ${CLIENT_HOST_FILE} 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    # clear server system cache
    #mpssh -f ${REDIS_SCRIPT_DIR}/servers 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    mpssh -f ${CLIENT_HOST_FILE} "sudo fm" > /dev/null 2>&1
    mpssh -f ${REDIS_SCRIPT_DIR}/servers "sudo fm" > /dev/null 2>&1
}

mpssh -f ${CLIENT_HOST_FILE} "mkdir -p $RESULT_LOG_PATH"
for num in ${SRV_NUMS[*]}
do
    # generate server host files
    ${GEN_HOST} server ${num} ${srv_start_idx} ${REDIS_SCRIPT_DIR}/servers
    #clear cache
    clear_cache
    #stop redis cluster
    stop_redis_cluster
    #sleep 2s
    sleep 1
    #Start redis cluster
    start_redis_cluster
    sleep 2

    #load data into redis_cluster
    #mpssh -f ${CLIENT_HOST_FILE} "${YCSB_PATH}/ycsb load redis -threads 10 -P /tmp/redis_bench/workload_load_${load_type} -P /tmp/redis_bench/redis.properties > ${RESULT_LOG_PATH}/load_${load_type}_result.log"
    ${YCSB_PATH}/ycsb load redis -threads 40 -P $WORKLOADS_DIR/workload_load_${load_type} -P ${BENCHMARK_DIR}/redis.properties > ${RESULT_LOG_PATH}/load_${load_type}_result.log
    for type in ${workload_types[*]}
    do
        #config cmdpath for pat
        mpssh -f ${CLIENT_HOST_FILE} "${YCSB_PATH}/ycsb run redis -threads 40 -P $WORKLOADS_DIR/workload_${type} -P ${BENCHMARK_DIR}/redis.properties -p maxexecutiontime=${maxtime} > ${RESULT_LOG_PATH}/redis_${num}_${type}.log"
        sleep 2
        clear_cache
    done

    #stop redis cluster
    sleep 3
    stop_redis_cluster
done
