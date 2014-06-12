#!/bin/sh
#stop object servers

echo "----- ${0##*/} -----"

echo "OCDET_CAPISTRANO:       " ${OCDET_CAPISTRANO:?"is not set"}

cd $OCDET_CAPISTRANO
HOSTROLEFILTER=object cap stop_swift -s _agent_type=object
