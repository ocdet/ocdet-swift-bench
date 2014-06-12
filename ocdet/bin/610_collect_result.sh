#!/bin/sh
#get benchmark and sar results
#. `dirname ${0}`/env
cd $OCDET_CAPISTRANO
cap get_sar_results -s _target_directory="$OCDET_BENCH_RESULT" -s _test_parameter=$OCDET_TEST_PARAMETERS
cap get_bench_results -s _target_directory="$OCDET_BENCH_RESULT" -s _test_parameter=$OCDET_TEST_PARAMETERS
