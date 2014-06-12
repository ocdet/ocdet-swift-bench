#!/bin/bash

echo "----- ${0##*/} -----"
## 必須変数チェック
echo "OCDET_BASEDIR:       " ${OCDET_BASEDIR:?"is not set"}
echo "PROXY_AUTH_METHOD:       " ${PROXY_AUTH_METHOD:?"is not set"}
echo "MEMCACHE_SERVERS:       " ${MEMCACHE_SERVERS:?"is not set"}
echo "KEYSTONE_ENDPOINT:       " ${KEYSTONE_ENDPOINT:?"is not set"}
echo "PROXY_WORKERS:       " ${PROXY_WORKERS:?"is not set"}
echo "PROXY_AUTH_USER:       " ${PROXY_AUTH_USER:?"is not set"}
echo "PROXY_AUTH_KEY:       " ${PROXY_AUTH_KEY:?"is not set"}

OUTPUT_FILE=proxy-server.conf

USER=`echo $PROXY_AUTH_USER | sed 's/:/_/'`

cd $OCDET_BASEDIR

if [ "$PROXY_AUTH_METHOD" = "keystone" ]
then
 AUTH="keystoneauth authtoken"
elif [ "$PROXY_AUTH_METHOD" = "tempauth" ]
then
 AUTH="tempauth"
fi

echo "
[DEFAULT]
#cert_file = /etc/swift/cert.crt
#key_file = /etc/swift/cert.key
bind_ip = 0.0.0.0
bind_port = 8080
workers = $PROXY_WORKERS
user = swift

log_headers = true
log_level = DEBUG

[pipeline:main]
pipeline = healthcheck cache $AUTH proxy-server

[app:proxy-server]
use = egg:swift#proxy
allow_account_management = true
account_autocreate = true
put_queue_depth = 20

[filter:tempauth]
use = egg:swift#tempauth
user_admin_admin = admin .admin .reseller_admin
user_$USER = $PROXY_AUTH_KEY .admin
user_test2_tester2 = testing2 .admin
user_test_tester3 = testing3

[filter:authtoken]
paste.filter_factory = keystone.middleware.auth_token:filter_factory
auth_host = $KEYSTONE_ENDPOINT
auth_port = 35357
auth_protocol = http
auth_uri = http://$KEYSTONE_ENDPOINT:5000/
admin_tenant_name = service
admin_user = swift
admin_password = password
delay_auth_decision = 1

[filter:keystoneauth]
use = egg:swift#keystoneauth
operator_roles = admin, swiftoperator

[filter:healthcheck]
use = egg:swift#healthcheck

[filter:cache]
use = egg:swift#memcache
memcache_servers = $MEMCACHE_SERVERS
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

