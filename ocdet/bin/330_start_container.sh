#!/bin/sh
#start container servers


echo "----- ${0##*/} -----"
echo "OCDET_CAPISTRANO:       " ${OCDET_CAPISTRANO:?"is not set"}
cd $OCDET_CAPISTRANO

HOSTROLEFILTER=container cap start_swift -s _agent_type=container
