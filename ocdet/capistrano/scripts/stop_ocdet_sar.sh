#!/bin/sh 

if [ -e /tmp/sar_process_id ] 
then
  kill -KILL `cat /tmp/sar_process_id`
  rm /tmp/sar_process_id
fi

sleep 2

result=` ps -ef | grep 'sar -A ' |grep -v grep | awk '{print $2}'` 
if [ "$result" == "" ]
then 
    exit 0 
fi

list=` ps -ef | grep 'sar -A ' |grep -v grep | awk '{print $2}'` 
for i in $list; do
 kill -KILL $i
done

sleep 2

result=` ps -ef | grep 'sar -A ' |grep -v grep | awk '{print $2}'` 

if [ "$result" != "" ]
then 
 echo "Failed to stop sar"
 echo $result
 exit 1
fi

exit 0
