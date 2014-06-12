#!/bin/sh

# dummy for test
#OCDET_BASEDIR=$HOME/`date +%s`
#OCDET_BENCH_RESULT=0
#OBJECT_SIZE=1024
#NUM_GETS=10
#NUM_PUTS=100
#CONCURRENCY=100
#SWIFT_BENCH_WORKERS=20
#NUM_CONTAINERS=200
#PROXY_NUM=1
#PROXY_AUTH_METHOD="keystone"
#AUTH_USER="test:tester"
#AUTH_KEY="testing"
#mkdir -p ${OCDET_BASEDIR}

echo "----- ${0##*/} -----"


## 必須変数のチェック
echo "OCDET_BASEDIR:       " ${OCDET_BASEDIR:?"is not set"}
echo "OBJECT_SIZE:         " ${OBJECT_SIZE:?"is not set"}
echo "NUM_GETS:            " ${NUM_GETS:?"is not set"}
echo "NUM_PUTS:            " ${NUM_PUTS:?"is not set"}
echo "CONCURRENCY:         " ${CONCURRENCY:?"is not set"}
echo "NUM_CONTAINERS:      " ${NUM_CONTAINERS:?"is not set"}
echo "PROXY_AUTH_METHOD:   " ${PROXY_AUTH_METHOD:?"is not set"}
echo "PROXY_AUTH_USER:     " ${PROXY_AUTH_USER:?"is not set"}
echo "PROXY_AUTH_KEY:      " ${PROXY_AUTH_KEY:?"is not set"}


## 認証設定
if [ "${PROXY_AUTH_METHOD}" == "tempauth" ];
then
    AUTH_VERSION="1.0"
elif [ "${PROXY_AUTH_METHOD}" == "keystone" ];
then
    AUTH_VERSION="2.0"
else
    OCDET_BENCH_RESULT=1
    exit ${OCDET_BENCH_RESULT}
fi


## Proxyの台数分をrole_serversから抽出する。
#BENCH_130_TARGET_PROXY=`grep proxy /opt/ocdet/role_servers.txt |head -n ${CONNECT_PROXY_NUM} |awk -F, '{print $2}'`
#if [ "${BENCH_130_TARGET_PROXY}" == "" ]; then
#    OCDET_BENCH_RESULT=1
#    exit ${OCDET_BENCH_RESULT}
#fi

## Proxyサーバ台数分のswift-bench用コンフィグを生成する。
## ファイル名：swift-bench.sh.<target_proxy_server_ip>
#for i in ${BENCH_130_TARGET_PROXY}; do

cd ${OCDET_BASEDIR}
cat << EOF > swift-bench.sh
#!/bin/sh
MYIP=\`/sbin/ifconfig | grep 192.168.20. | sed -n '/dr:/{;s/.*dr:\([0-9.]\+\) .*/\1/;p;}'\`
cd /tmp/$OCDET_TESTID
. ./find_target_proxy.sh \$MYIP

swift -A http://\$TARGET_PROXY_ADDRESS:8080/auth/v${AUTH_VERSION} -U ${PROXY_AUTH_USER} -K ${PROXY_AUTH_KEY} stat

swift-bench \\
 -A http://\$TARGET_PROXY_ADDRESS:8080/auth/v${AUTH_VERSION} \\
 -U ${PROXY_AUTH_USER} \\
 -K ${PROXY_AUTH_KEY} \\
 -c ${CONCURRENCY} \\
 -s ${OBJECT_SIZE} \\
 -n ${NUM_PUTS} \\
 -g ${NUM_GETS} \\
 -V ${AUTH_VERSION}
EOF
#done

# check file
if [ ! -s "${OCDET_BASEDIR}/swift-bench.sh" ]; then
   exit 1
fi

exit 0

