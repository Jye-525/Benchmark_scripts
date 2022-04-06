#!/bin/bash

CLIENT_HOST_FILE="/home/jye20/symbios/syn_test/redis/client_host_file"
YCSB_PATH="/home/jye20/symbios/ycsb-0.17.0/bin"
WORKLOADS_DIR="/home/jye20/symbios/syn_test/redis/workloads/"
RESULT_LOG_PATH="/tmp/redis_test_log"
BENCHMARK_DIR="/home/jye20/symbios/syn_test/redis/"

load_type=$1
num=$2
maxtime=$3
t_num=$4

mpssh -f ${CLIENT_HOST_FILE} "${YCSB_PATH}/ycsb run redis -threads ${t_num} -P $WORKLOADS_DIR/workload_${load_type} -P ${BENCHMARK_DIR}/redis.properties -p maxexecutiontime=${maxtime} > ${RESULT_LOG_PATH}/redis_${num}_${load_type}.log"
