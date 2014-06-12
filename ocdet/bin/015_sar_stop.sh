#!/bin/sh
#stop sar proesses in all instances 
#. `dirname ${0}`/env
echo "----- ${0##*/} -----"
 
echo "OCDET_CAPISTRANO:       " ${OCDET_CAPISTRANO:?"is not set"}
cd $OCDET_CAPISTRANO

cap stop_sar
