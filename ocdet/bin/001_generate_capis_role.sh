#!/bin/sh -x

# dummy for test
#OCDET_BASEDIR=$HOME/`date +%s`
#ROLE_SERVERS=/opt/ocdet/iij_role_servers.txt
#TEMP_ROLE_FILE=${OCDET_BASEDIR}/role.rb
#ACCOUNT_PAR_ZONE=1
#CONTAINER_PAR_ZONE=1
#OBJECT_PAR_ZONE=1
#PROXY_NUM=1
#SWIFT_BENCH_NUM=1
#ZONE=5
#mkdir -p ${OCDET_BASEDIR}

echo "----- ${0##*/} -----"

## 必須変数のチェック
echo "OCDET_BASEDIR:       " ${OCDET_BASEDIR:?"is not set"}
echo "ROLE_SERVERS:        " ${ROLE_SERVERS:?"is not set"}
echo "TEMP_ROLE_FILE:      " ${TEMP_ROLE_FILE:?"is not set"}
echo "ACCOUNT_PAR_ZONE:    " ${ACCOUNT_PAR_ZONE:?"is not set"}
echo "CONTAINER_PAR_ZONE:  " ${CONTAINER_PAR_ZONE:?"is not set"}
echo "OBJECT_PAR_ZONE:     " ${OBJECT_PAR_ZONE:?"is not set"}
echo "PROXY_NUM:           " ${PROXY_NUM:?"is not set"}
echo "SWIFT_BENCH_NUM:     " ${SWIFT_BENCH_NUM:?"is not set"} 
echo "ZONE:                " ${ZONE:?"is not set"} 

# role リストの仕様
# 
# role :all,            全サーバのアドレス
# role :account,        アカウントサーバ
# role :container,      コンテナサーバ
# role :object,         オブジェクトサーバ
# role :proxy,          プロキシ
# role :load_generator, ロードジェネレータ
# role :load_balancer,  バランサー


# 
TEMP_SERVER_FILE=/tmp/server_$RANDOM

# init
cd ${OCDET_BASEDIR}
cp /dev/null ${TEMP_ROLE_FILE}
ORIGINAL_FILE=""


# load role file
ORIGINAL_FILE=`cat ${ROLE_SERVERS}`
if [ "${ORIGINAL_FILE}" == "" ]; then
    echo "Cani\'t load ${ROLE_SERVERS}"
    exit 1
fi

# Create "role :all" that include All Server List 
echo -n "role :all  " >> ${TEMP_ROLE_FILE}
for i in `echo "${ORIGINAL_FILE}" | grep -v ^$ |awk -F, '{print $2}'`
do
    echo -n ",\"${i}\" " >> ${TEMP_ROLE_FILE}
done
echo >> ${TEMP_ROLE_FILE}

# Create "role :xxxxx" for each functions 
# extract_list=("load_generator" "load_balancer" "proxy" "account" "container" "object")
extract_list=("load_generator"   "proxy"         "account"          "container"            "object")
server_count=(${SWIFT_BENCH_NUM} ${PROXY_NUM}    `expr ${ACCOUNT_PAR_ZONE} \* ${ZONE}` `expr ${CONTAINER_PAR_ZONE} \* ${ZONE}` `expr ${OBJECT_PAR_ZONE} \* ${ZONE}`)

for i in {0..4}
do
  echo -n "role :${extract_list[i]}  " >> ${TEMP_ROLE_FILE}

  for j in `echo "${ORIGINAL_FILE}" | grep -v ^$ | grep ${extract_list[i]} |head -n ${server_count[i]} | awk -F, '{print $2}'`
  do
    echo -n ",\"${j}\" " >> ${TEMP_ROLE_FILE}
    echo ",\"${j}\" " >> ${TEMP_SERVER_FILE}
  done

  echo >> ${TEMP_ROLE_FILE}
 
done

#Create "role: work". it's for deduplicate servers.

#This translation is for StarBED system. In starbed 192.168.[1-4]0.XXX are same server.
sed -i -e s/192.168.[2-4]0/192.168.10/g ${TEMP_SERVER_FILE}

echo -n "role :work  " >> ${TEMP_ROLE_FILE}
sort -u ${TEMP_SERVER_FILE} | tr -d '\n'  >> ${TEMP_ROLE_FILE}

# Check file
if [ ! -s "${TEMP_ROLE_FILE}" ]; then
   exit 1
fi

rm -rf $TEMP_SERVER_FILE
exit 0

