#!/bin/sh
#check swift servers


echo "----- ${0##*/} -----"

echo "OCDET_CAPISTRANO:       " ${OCDET_CAPISTRANO:?"is not set"}
cd $OCDET_CAPISTRANO

cap swift_started
