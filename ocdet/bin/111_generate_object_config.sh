#!/bin/bash

echo "----- ${0##*/} -----"

## 必須変数のチェック
echo "OCDET_BASEDIR:       " ${OCDET_BASEDIR:?"is not set"}
echo "SWIFT_DIR:       " ${SWIFT_DIR:?"is not set"}
echo "OBJECT_WORKERS:       " ${OBJECT_WORKERS:?"is not set"}

OUTPUT_FILE=object-server.conf

cd $OCDET_BASEDIR

echo " 
[DEFAULT]
devices = $SWIFT_DIR
mount_check = false
bind_port = 6000
user = swift
#log_facility = LOG_LOCAL4

workers = $OBJECT_WORKERS

log_headers = true
log_level = DEBUG

[pipeline:main]
pipeline = object-server

[app:object-server]
use = egg:swift#object

[object-replicator]
vm_test_mode = yes

[object-updater]

[object-auditor]
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

