#!/bin/sh
#start sar proesses in all instances


echo "----- ${0##*/} -----"

echo "OCDET_CAPISTRANO:       " ${OCDET_CAPISTRANO:?"is not set"}

cd $OCDET_CAPISTRANO

echo cap start_sar
cap start_sar
