#!/bin/sh

TARGET_DEVICE=/dev/sdb
SWIFT_DIR=/swift
IPADDRESS=`ifconfig eth1 | perl -n -e 'if (m/inet addr:([\d\.]+)/g) { print $1 }'`
for x in {1..4}; do mkdir -p $SWIFT_DIR/$x/node/sdb$x ; done

mkdir -p /etc/swift/object-server /etc/swift/container-server /etc/swift/account-server /var/run/swift
chown -R swift:swift /etc/swift $SWIFT_DIR/ /var/run/swift

#start swift when OS is booted.
cp /etc/rc.local /etc/rc.local.bak

# TODO this code may not work?
sed -i -e "s,^exit,mkdir /var/run/swift\nchown swift:swift /var/run/swift\nexit,g" /etc/rc.local

# 
echo "
uid = swift
gid = swift
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
address = $IPADDRESS

[account6012]
max connections = 25
path = $SWIFT_DIR/1/node/
read only = false
lock file = /var/lock/account6012.lock

[account6022]
max connections = 25
path = $SWIFT_DIR/2/node/
read only = false
lock file = /var/lock/account6022.lock

[account6032]
max connections = 25
path = $SWIFT_DIR/3/node/
read only = false
lock file = /var/lock/account6032.lock

[account6042]
max connections = 25
path = $SWIFT_DIR/4/node/
read only = false
lock file = /var/lock/account6042.lock

[container6011]
max connections = 25
path = $SWIFT_DIR/1/node/
read only = false
lock file = /var/lock/container6011.lock

[container6021]
max connections = 25
path = $SWIFT_DIR/2/node/
read only = false
lock file = /var/lock/container6021.lock

[container6031]
max connections = 25
path = $SWIFT_DIR/3/node/
read only = false
lock file = /var/lock/container6031.lock

[container6041]
max connections = 25
path = $SWIFT_DIR/4/node/
read only = false
lock file = /var/lock/container6041.lock

[object6010]
max connections = 25
path = $SWIFT_DIR/1/node/
read only = false
lock file = /var/lock/object6010.lock

[object6020]
max connections = 25
path = $SWIFT_DIR/2/node/
read only = false
lock file = /var/lock/object6020.lock

[object6030]
max connections = 25
path = $SWIFT_DIR/3/node/
read only = false
lock file = /var/lock/object6030.lock

[object6040]
max connections = 25
path = $SWIFT_DIR/4/node/
read only = false
lock file = /var/lock/object6040.lock
" > /etc/rsyncd.conf

sed -i -e "s/disable\s=\syes/disable = no/g" /etc/xinetd.d/rsync

echo "
[DEFAULT]
bind_ip = 0.0.0.0
bind_port = 8080
user = swift
log_facility = LOG_LOCAL1

[pipeline:main]
pipeline = healthcheck cache tempauth proxy-server

[app:proxy-server]
use = egg:swift#proxy
allow_account_management = true
account_autocreate = true

[filter:tempauth]
use = egg:swift#tempauth
user_admin_admin = admin .admin .reseller_admin
user_test_tester = testing .admin
user_test2_tester2 = testing2 .admin
user_test_tester3 = testing3

[filter:healthcheck]
use = egg:swift#healthcheck

[filter:cache]
use = egg:swift#memcache
" > /etc/swift/proxy-server.conf

echo "
[swift-hash]
# random unique string that can never change (DO NOT LOSE)
swift_hash_path_suffix = changeme
" > /etc/swift/swift.conf

for x in {1..4}; do

    echo "[DEFAULT]
devices = $SWIFT_DIR/$x/node
mount_check = false
bind_port = 60${x}2
user = swift
log_facility = LOG_LOCAL2

[pipeline:main]
pipeline = account-server

[app:account-server]
use = egg:swift#account

[account-replicator]
vm_test_mode = yes

[account-auditor]

[account-reaper]
" > /etc/swift/account-server/$x.conf

echo "[DEFAULT]
devices = $SWIFT_DIR/$x/node
mount_check = false
bind_port = 60${x}1
user = swift
log_facility = LOG_LOCAL2

[pipeline:main]
pipeline = container-server

[app:container-server]
use = egg:swift#container

[container-replicator]
vm_test_mode = yes

[container-updater]

[container-auditor]

[container-sync]
" > /etc/swift/container-server/$x.conf

echo "[DEFAULT]
devices = $SWIFT_DIR/$x/node
mount_check = false
bind_port = 60${x}0
user = swift
log_facility = LOG_LOCAL2

[pipeline:main]
pipeline = object-server

[app:object-server]
use = egg:swift#object

[object-replicator]
vm_test_mode = yes

[object-updater]

[object-auditor]
" > /etc/swift/object-server/$x.conf

done

mkdir -p /home/swift/bin/

echo "
#!/bin/bash

swift-init all stop
find /var/log/swift -type f -exec rm -f {} \;
sudo umount /sdb1
sudo mkfs.ext4 -I 512 /dev/sdb1
sudo mkfs.ext4 -I 512 ${TARGET_DEVICE}1
sudo mount -t ext4 ${TARGET_DEVICE}1 ${SWIFT_DIR}
for x in {1..4}; do mkdir -p $SWIFT_DIR/$x/node/sdb$x ; done
chown -R swift:swift /etc/swift $SWIFT_DIR/ /var/run/swift

sudo rm -f /var/log/debug /var/log/messages /var/log/rsyncd.log /var/log/syslog
find /var/cache/swift* -type f -name *.recon -exec rm -f {} \;
sudo service rsyslog restart
sudo service memcached restart
" > /home/swift/bin/resetswift

echo "
#!/bin/bash

cd /etc/swift

rm -f *.builder *.ring.gz backups/*.builder backups/*.ring.gz

swift-ring-builder object.builder create 18 3 1
swift-ring-builder object.builder add z1-$IPADDRESS:6010/sdb1 1
swift-ring-builder object.builder add z2-$IPADDRESS:6020/sdb2 1
swift-ring-builder object.builder add z3-$IPADDRESS:6030/sdb3 1
swift-ring-builder object.builder add z4-$IPADDRESS:6040/sdb4 1
swift-ring-builder object.builder rebalance
swift-ring-builder container.builder create 18 3 1
swift-ring-builder container.builder add z1-$IPADDRESS:6011/sdb1 1
swift-ring-builder container.builder add z2-$IPADDRESS:6021/sdb2 1
swift-ring-builder container.builder add z3-$IPADDRESS:6031/sdb3 1
swift-ring-builder container.builder add z4-$IPADDRESS:6041/sdb4 1
swift-ring-builder container.builder rebalance
swift-ring-builder account.builder create 18 3 1
swift-ring-builder account.builder add z1-$IPADDRESS:6012/sdb1 1
swift-ring-builder account.builder add z2-$IPADDRESS:6022/sdb2 1
swift-ring-builder account.builder add z3-$IPADDRESS:6032/sdb3 1
swift-ring-builder account.builder add z4-$IPADDRESS:6042/sdb4 1
swift-ring-builder account.builder rebalance
"  > /home/swift/bin/remakerings


chown -R swift:swift /home/swift/bin
chmod 0755  /home/swift/bin/*
sudo -u swift /home/swift/bin/remakerings

chkconfig memcached on
chkconfig openstack-swift-account on
chkconfig openstack-swift-container on
chkconfig openstack-swift-object on
chkconfig openstack-swift-proxy on
