#!/bin/sh
yum remove -y xfsprogs
yum remove -y python-netifaces python-nose
yum remove -y memcached
yum remove -y xinetd rsync
yum remove -y openstack-swift openstack-swift-proxy openstack-swift-account openstack-swift-container openstack-swift-object
yum remove -y python-webob
rpm -ev epel-release-6-7
