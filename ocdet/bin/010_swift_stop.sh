#!/bin/sh -x
#stop swift instances
#. `dirname ${0}`/env
cd $OCDET_CAPISTRANO
cap stop_service
cap swift_stopped
