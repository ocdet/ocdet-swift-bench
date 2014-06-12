#!/bin/sh
yum install -y wget > null
wget ftp://ftp.iij.ad.jp/pub/linux/fedora/epel/6/i386/epel-release-6-7.noarch.rpm
rpm -ivh epel-release-6-7.noarch.rpm > null
yum install -y openstack-swift openstack-swift-proxy openstack-swift-account openstack-swift-container openstack-swift-object > null
yum install -y xinetd rsync > null
yum install -y memcached > null
yum install -y python-netifaces python-nose > null
yum install -y xfsprogs > null
yum install -y python-webob > null
