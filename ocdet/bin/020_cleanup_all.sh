#!/bin/sh
#stop swift instances
#. `dirname ${0}`/env

echo "----- ${0##*/} -----"
echo "OCDET_CAPISTRANO:       " ${OCDET_CAPISTRANO:?"is not set"}
echo "SWFIT_DIR:              " ${SWIFT_DIR:?"is not set"}
echo "OCDET_DEVICE_PREFIX:    " ${OCDET_DEVICE_PREFIX:?"is not set"}

cd $OCDET_CAPISTRANO
cap cleanup_all
