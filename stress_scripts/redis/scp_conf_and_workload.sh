#!/bin/bash

if [ $# -ne 1 ];
then
    echo "Usage: ./scp_conf_and_workload.sh <light|heavy>"
    exit
fi

REDIS_SCRIPT_DIR="/home/cc/common/scripts/redis/"
CLIENT_HOST_FILE="/home/cc/common/syn_test/redis/client_host_file"
BENCHMARK_DIR="/home/cc/common/syn_test/redis/"

type=$1
recordcount=`cat ${BENCHMARK_DIR}/workloads/workload_load_${type}|grep "recordcount"|awk -F"=" '{print$2}'`
insertcount=$(expr $recordcount / 8)

mpssh -f ${CLIENT_HOST_FILE} "mkdir -p /tmp/redis_bench"
CLIENTS=`cat $CLIENT_HOST_FILE | awk '{print $1}'`
REDIS_SERVER=`cat ${REDIS_SCRIPT_DIR}/servers | head -1`
SRV_NUMS=`cat ${REDIS_SCRIPT_DIR}/servers|wc -l`


idx=0
for client in ${CLIENTS[@]}
do
    port=6379
    echo "redis.host=${REDIS_SERVER}" > ${BENCHMARK_DIR}/redis.properties
    echo "redis.port=${port}" >> ${BENCHMARK_DIR}/redis.properties
    echo "redis.cluster=true" >> ${BENCHMARK_DIR}/redis.properties

    insert_offset=`expr $idx \* ${insertcount}`
    sed -i "/^insertstart=/cinsertstart=${insert_offset}" ${BENCHMARK_DIR}/workloads/workload_load_${type}

    ssh ${client} "sh -c \"cp ${BENCHMARK_DIR}/redis.properties /tmp/redis_bench/redis.properties;cp ${BENCHMARK_DIR}/workloads/workload_load_${type} /tmp/redis_bench/workload_load_${type}\""
    ((idx=idx+1))
done

