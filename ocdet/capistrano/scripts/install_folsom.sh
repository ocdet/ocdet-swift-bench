#!/bin/sh

wget ftp://ftp.iij.ad.jp/pub/linux/fedora/epel/6/i386/epel-release-6-7.noarch.rpm
rpm -ivh epel-release-6-7.noarch.rpm

mkdir -p /etc/swift
rpm -e python-Paste-1.7.5.1-1.noarch
yum -y install openstack-swift
yum -y install openstack-swift-doc.noarch
yum -y install openstack-swift-account.noarch
yum -y install openstack-swift-container.noarch
yum -y install openstack-swift-object.noarch
yum -y install openstack-swift-proxy.noarch
yum -y install python-swiftclient-doc.noarch

