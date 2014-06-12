#!/bin/sh

#fdisk with shell script

TARGET_DEVICE=/dev/sdb
MOUNT_DIR=/swift

umount ${MOUNT_DIR}

fdisk $TARGET_DEVICE <<\__EOF__
d
w
__EOF__
