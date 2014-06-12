#!/bin/sh -x 

# Writing test results to database;

echo "----- ${0##*/} -----"

echo "OCDET_TESTID:       " ${OCDET_TESTID:?"is not set"}
echo "OCDET_CAPISTRANO:    " ${OCDET_CAPISTRANO:?"is not set"}

OCDET_PERFDB_PATH=/var/ocdet/testresult.db
CREATEDB=${OCDET_CAPISTRANO}/utils/create_table.sql
# create tables

echo .read $CREATEDB | sqlite3 $OCDET_PERFDB_PATH

# create test record

PREV_MESSAAGES=$LC_LC_MESSAGES
export LC_MESSAGES=C
PREV_TIME=$LC_TIME 
export LC_TIME=C 
python 711_regist_test_data.py $OCDET_TESTID $OCDET_PERFDB_PATH /var/ocdet/
export LC_TIME=$PREV_TIME
export LC_MESSAGES=$PREV_MESSAAGES

#create host columned data file.
sh -x 712_create_pivot.sh $OCDET_TESTID

#create graph
