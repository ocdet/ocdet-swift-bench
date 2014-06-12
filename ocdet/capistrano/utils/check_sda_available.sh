#!/bin/sh

IP_ADDR_ARRAY=()

for i in {10..148}
do
   IP_ADDR_ARRAY=("${IP_ADDR_ARRAY[@]}" "192.168.10.${i}")
done

NUM=0
for IP in ${IP_ADDR_ARRAY[@]}
do

  RESULT=`ssh ${IP} "df -h | grep sda" |  awk '{print $5}'`
  echo "${IP} : ${RESULT}"
  NUM=`expr ${NUM} + 1`
done

