#!/bin/sh
yum install -y wget > /dev/null
wget ftp://ftp.iij.ad.jp/pub/linux/fedora/epel/6/i386/epel-release-6-7.noarch.rpm
rpm -ivh epel-release-6-7.noarch.rpm > /dev/null
yum install -y openstack-swift openstack-swift-proxy openstack-swift-account openstack-swift-container openstack-swift-object > /dev/null
yum install -y xinetd rsync > /dev/null
yum install -y memcached > /dev/null
yum install -y python-netifaces python-nose > /dev/null
yum install -y xfsprogs > /dev/null
yum install -y python-webob > /dev/null
