#!/bin/sh
#copy benchmark script files to instances

echo "----- ${0##*/} -----"

echo "OCDET_CAPISTRANO:       " ${OCDET_CAPISTRANO:?"is not set"}
echo "OCDET_SWIFT_CONFIG_DIR: " ${OCDET_SWIFT_CONFIG_DIR:?"is not set"}

cd $OCDET_CAPISTRANO
cap put_benches -s swift_bench_dir=$OCDET_SWIFT_CONFIG_DIR

if [ $? != 0 ]; then
   echo "Error: ${0}"
   exit $?
fi
