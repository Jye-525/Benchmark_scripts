#!/bin/bash
GEN_HOST="/home/jye20/symbios/scripts/gen_hosts.sh"
MONGO_SCRIPT_DIR="/home/jye20/symbios/scripts/mongo/"
RESULT_LOG_PATH="/tmp/mongo_test_log"
CLIENT_HOST_FILE="/home/jye20/symbios/syn_test/mongo/client_host_file"
PAT_PATH="/home/jye20/symbios/syn_test/pat/collect/"
YCSB_PATH="/home/jye20/symbios/ycsb-0.17.0/bin"

#redis workloads
WORKLOADS_DIR="/home/jye20/symbios/syn_test/mongo/workloads/"
BENCHMARK_DIR="/home/jye20/symbios/syn_test/mongo/"

load_type=$1
num=$2
maxtime=$3
t_num=$4
mode=$5

if [ ${mode} == "sync" ];
then
    mpssh -f ${CLIENT_HOST_FILE} "${YCSB_PATH}/ycsb run mongodb -threads ${t_num} -P $WORKLOADS_DIR/workload_${load_type} -P ${BENCHMARK_DIR}/mongodb.properties -p maxexecutiontime=${maxtime} > ${RESULT_LOG_PATH}/mongo_${mode}_${num}_${load_type}.log"
else
    mpssh -f ${CLIENT_HOST_FILE} "${YCSB_PATH}/ycsb run mongodb-async -threads ${t_num} -P $WORKLOADS_DIR/workload_${load_type} -P ${BENCHMARK_DIR}/mongodb.properties -p maxexecutiontime=${maxtime} > ${RESULT_LOG_PATH}/mongo_${mode}_${num}_${load_type}.log"
fi
