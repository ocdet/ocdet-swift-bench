#!/bin/bash

echo "----- ${0##*/} -----"
echo "OCDET_BASEDIR:       " ${OCDET_BASEDIR:?"is not set"}
echo "SWIFT_DIR:       " ${SWIFT_DIR:?"is not set"}
echo "CONTAINER_WORKERS:       " ${CONTAINER_WORKERS:?"is not set"}

OUTPUT_FILE=container-server.conf

cd $OCDET_BASEDIR

echo " 
[DEFAULT]
devices = $SWIFT_DIR
mount_check = false
bind_port = 6001
user = swift
#log_facility = LOG_LOCAL3

workers = $CONTAINER_WORKERS

log_headers = true
log_level = DEBUG

[pipeline:main]
pipeline = container-server

[app:container-server]
use = egg:swift#container

[container-replicator]
vm_test_mode = yes

[container-updater]

[container-auditor]

[container-sync]
" > $OUTPUT_FILE


if [ ! -f "$OUTPUT_FILE" ]
then
 echo "file $OUTPUT_FILE not exist"
 exit 1
fi

if [ ! -s "$OUTPUT_FILE" ]
then
 echo "file $OUTPUT_FILE size zero"
 exit 1
fi

exit 0

