#!/bin/bash

route_port=27017
get_router_servers(){
    route_srvs_str=""
    route_srvs=`cat /home/cc/common/scripts/mongo/router_servers|awk '{print $1}'`
    for route_srv in ${route_srvs[@]}
    do
        route_srvs_str=${route_srvs_str}${route_srv}":"${route_port}","
    done
    # remove the last ','
    route_srvs_str=${route_srvs_str::-1}
    echo ${route_srvs_str}
}

str=$( get_router_servers )

echo "str is ${str}" 
