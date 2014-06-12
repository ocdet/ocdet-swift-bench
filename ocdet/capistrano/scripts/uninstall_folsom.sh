#!/bin/sh
yum remove xfsprogs
yum remove python-netifaces python-nose
yum remove memcached
yum remove xinetd rsync
yum remove openstack-swift openstack-swift-proxy openstack-swift-account openstack-swift-container openstack-swift-object
yum remove python-webob
rpm -e epel-release-6-7
