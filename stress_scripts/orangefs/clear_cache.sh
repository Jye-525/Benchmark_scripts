#!/bin/bash

if [ $# -ne 1 ];
then
   echo "Usage; ./clear_cache <host_lists>"
   exit
fi
host_lists=$1
mpssh -f ${host_lists} 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
