#!/bin/bash
IO_Type=$1
is_sync=$2   #false or true
log_path="/home/cc/common/syn_test/mongo/log"
mongo_dir="/home/cc/common/scripts/mongo"
ycsb_dir="/home/cc/common/ycsb-0.17.0/bin"
workloads="/home/cc/common/syn_test/mongo/workloads"

if [ ${IO_Type} == "write_only" ];
then
   if [ ${is_sync} == "true" ];
   then
       #write only
       ${ycsb_dir}/ycsb load mongodb -s -threads 10 -P ${workloads}/workload_${IO_Type} -P ./mongodb.properties > ${log_path}/load_sync.log
       ${ycsb_dir}/ycsb run mongodb -s -threads 10 -P ${workloads}/workload_${IO_Type} -P ./mongodb.properties > ${log_path}/r_sync_${IO_Type}.log
   else
       #write async
       ${ycsb_dir}/ycsb load mongodb-async -s -threads 10 -P ${workloads}/workload_${IO_Type} -P ./mongodb.properties > ${log_path}/load_async.log
       ${ycsb_dir}/ycsb run mongodb-async -s -threads 10 -P ${workloads}/workload_${IO_Type} -P ./mongodb.properties > ${log_path}/r_async_${IO_Type}.log
   fi
elif [ ${IO_Type} == "read_only" ];
then
    if [ ${is_sync} == "true" ];
    then
       #read only
       ${ycsb_dir}/ycsb run mongodb -s -threads 10 -P ${workloads}/workload_${IO_Type} -P ./mongodb.properties > ${log_path}/r_sync_${IO_Type}.log
    else
       #read only
       ${ycsb_dir}/ycsb run mongodb-async -s -threads 10 -P ${workloads}/workload_${IO_Type} -P ./mongodb.properties > ${log_path}/r_async_${IO_Type}.log
    fi
fi

