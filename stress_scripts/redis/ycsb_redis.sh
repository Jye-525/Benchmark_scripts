#!/bin/bash
IO_Type=$1

log_path="/home/cc/common/syn_test/redis/log/"
redis_script_dir="/home/cc/common/scripts/redis/"
ycsb_path="/home/cc/common/ycsb-0.17.0/bin"
workload="/home/cc/common/syn_test/redis/workloads"

if [ ${IO_Type} == "load" ];
then
  ${ycsb_path}/ycsb load redis -s -threads 40 -P ${workload}/workload_${IO_Type} -P ./redis.properties > ${log_path}"/load.log"
elif [ ${IO_Type} == "write_heavy" ];
then
   #write only
   #${ycsb_path}/ycsb load redis -s -threads 10 -P ${workload}/workload_${IO_Type} -P ./redis.properties > ${log_path}"/load.log"
   #mpirun -f ./clients -ppn 40 ${ycsb_path}/ycsb run redis -threads 1 -P ${workload}/workload_${IO_Type} -P /home/cc/common/syn_test/redis/redis.properties > ${log_path}"/w_${IO_Type}.log"
   mpssh -f ./clients "${ycsb_path}/ycsb run redis -threads 40 -P ${workload}/workload_${IO_Type} -P /home/cc/common/syn_test/redis/redis.properties > \"/home/cc/w_${IO_Type}.log\""
elif [ ${IO_Type} == "read_heavy" ];
then
   #mpirun -f ./clients -ppn 20 ${ycsb_path}/ycsb run redis -threads 1 -P ${workload}/workload_${IO_Type} -P ./redis.properties > ${log_path}"/r_${IO_Type}.log"
   mpssh -f ./clients "${ycsb_path}/ycsb run redis -threads 40 -P ${workload}/workload_${IO_Type} -P /home/cc/common/syn_test/redis/redis.properties > \"/home/cc/w_${IO_Type}.log\""
fi

