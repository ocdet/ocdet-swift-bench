#!/bin/sh -x 

if [ $# -ne 1 ]; then
  exit 1
fi

echo sar -A -o $1
nohup sar -A -o $1 1 >> /dev/null &
echo $! > /tmp/sar_process_id
sleep 1
ps -ef | grep sar | grep -v grep 
