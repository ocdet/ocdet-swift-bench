#!/bin/sh

#fdisk with shell script

TARGET_DEVICE=/dev/sdb
SWIFT_DIR=/swift

mkdir -p ${SWIFT_DIR} 
mkfs.xfs -f -i size=1024 ${TARGET_DEVICE}1
echo  /dev/sdb1               /swift                  xfs     noatime,nodiratime,nobarrier,logbufs=8 0 0 >> /etc/fstab

mount ${SWIFT_DIR}
chown -R swift:swift /swift
