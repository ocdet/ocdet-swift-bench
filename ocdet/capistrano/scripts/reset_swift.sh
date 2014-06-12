#!/bin/bash

TARGET_DEVICE=/dev/sdb
#SWIFT_DIR=/swift

swift-init all stop
find /var/log/swift -type f -exec rm -f {} \;
sudo umount $SWIFT_DIR
sudo mkfs.ext4 -f -I 512 $TARGET_DEVICE
sudo mount $SWIFT_DIR
sudo for x in {1..4}; do mkdir -p $SWIFT_DIR/$x/node/sdb$x ; done
sudo chown swift:swift $SWIFT_DIR/*

sudo rm -f /var/log/debug /var/log/messages /var/log/rsyncd.log /var/log/syslog
find /var/cache/swift* -type f -name *.recon -exec rm -f {} \;
sudo service memcached restart

