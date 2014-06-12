#!/bin/sh
MYIP=`/sbin/ifconfig | grep 172.16.110. | sed -n '/dr:/{;s/.*dr:\([0-9.]\+\) .*/\1/;p;}'`
. ./find_target_proxy.sh $MYIP
swift-bench \
 -A http://$TARGET_PROXY_ADDRESS:8080/auth/v2.0 \
 -U test:tester \
 -K testing \
 -c 100 \
 -s 1024 \
 -n 100 \
 -g 10 \
 -V 2.0
