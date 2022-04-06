#!/bin/bash
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
MONGO_INSTALL_DIR=/mnt/nvme/jye20/mongo_cluster
MONGO_CONF_SRV_DIR=${MONGO_INSTALL_DIR}/mongod
MONGO_SHARD_SRV_DIR=${MONGO_INSTALL_DIR}/mongod_shard
MONGO_ROUTER_SRV_DIR=${MONGO_INSTALL_DIR}/mongos
MONGO_DIR=/home/jye20/install/mongodb-5.0.6/bin
CONFIG_SVR_PORT=57040
SHARD_SVR_PORT=37017
ROUTER_SVR_PORT=17017
CONFIG_SVR_CONF_FILE="mongod_config.conf"
SHARD_SVR_CONF_FILE="mongod_shard.conf"
ROUTER_CONF_FILE="mongos.conf"
