#!/bin/bash

echo "----- ${0##*/} -----"
## 必須変数チェック
echo "OCDET_BASEDIR:       " ${OCDET_BASEDIR:?"is not set"}
echo "SWIFT_DIR:       " ${SWIFT_DIR:?"is not set"}
echo "ACCOUNT_WORKERS:       " ${ACCOUNT_WORKERS:?"is not set"}

OUTPUT_FILE=account-server.conf

cd $OCDET_BASEDIR

echo " 
[DEFAULT]
devices = $SWIFT_DIR
mount_check = false
bind_port = 6002
user = swift
#log_facility = LOG_LOCAL2

workers = $ACCOUNT_WORKERS

log_headers = true
log_level = DEBUG

[pipeline:main]
pipeline = account-server

[app:account-server]
use = egg:swift#account

[account-replicator]
vm_test_mode = yes

[account-auditor]

[account-reaper]
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

