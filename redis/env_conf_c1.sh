#!/bin/bash
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CLUSTER_INSTALL_DIR=/mnt/nvme/jye20/redis_cluster1
REDIS_DIR=/home/jye20/install/redis-6.2.6/bin/
CONFIG_FILE=redis.conf
HOSTNAME_POSTFIX=""
REDIS_NODES=`cat ${CWD}/servers | awk '{print $1}'`
N_REDIS_NODES=`cat ${CWD}/servers |wc -l`
REDIS_PORT_BASE=6379
