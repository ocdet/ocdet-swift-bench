#!/bin/sh

if [ "$1" == "" ]; then
   echo "need argument: PREFIX ADDRESS"
   echo "ex) ./check_host_available 192.168.10"
   exit 1
fi

PREFIX=$1

IP_ADDR_ARRAY=()

for i in {10..148}
do
   IP_ADDR_ARRAY=("${IP_ADDR_ARRAY[@]}" "${PREFIX}.${i}")
done

NUM=0
for IP in ${IP_ADDR_ARRAY[@]}
do
  ping ${IP} -c 1 >> /dev/null
  if [ $? == 0 ] ;
  then
    echo "${IP} : OK"
  else
    echo "${IP} : ** NG **"
  fi
  NUM=`expr ${NUM} + 1`
done

