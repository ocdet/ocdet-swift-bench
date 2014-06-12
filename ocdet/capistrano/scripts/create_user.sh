#!/bin/sh
groupadd swift
useradd -d /home/swift -m -g swift swift
echo swift:swift | chpasswd
