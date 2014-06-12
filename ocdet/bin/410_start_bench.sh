#!/bin/sh
#start benchmark

echo "----- ${0##*/} -----"

echo "OCDET_CAPISTRANO:       " ${OCDET_CAPISTRANO:?"is not set"}

cd $OCDET_CAPISTRANO
echo "put bench"
cap put_benches
echo "run bench"
cap run_bench
echo "done"
