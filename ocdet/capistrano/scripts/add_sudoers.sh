#!/bin/sh

SUDOERS=/etc/sudoers
chmod 0640 $SUDOERS
echo "ocdet        ALL=(ALL) NOPASSWD: ALL" >> $SUDOERS
chmod 0440 $SUDOERS
