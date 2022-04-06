#!/bin/bash

if [ $# -ne 2 ];
then
    echo "usage: ./fio-server.sh <operation> <host_lists>"
    echo "e.g., ./fio-server.sh start|stop /home/jye20/symbios/syn_test/orangefs/client_host_file"
    exit
fi

ops=$1
#host_file="/home/jye20/symbios/syn_test/orangefs/client_host_file"
host_file=$2

if [ ${ops} == "start" ];
then
   mpssh -f ${host_file} 'fio --server --daemonize="$(hostname)"'
fi

if [ ${ops} == "stop" ];
then
   mpssh -f ${host_file} 'killall fio'
fi
