#!/bin/sh
#start proxy servers


echo "----- ${0##*/} -----"
echo "OCDET_CAPISTRANO:       " ${OCDET_CAPISTRANO:?"is not set"}
cd $OCDET_CAPISTRANO
HOSTROLEFILTER=proxy cap start_swift -s _agent_type=proxy
HOSTROLEFILTER=
