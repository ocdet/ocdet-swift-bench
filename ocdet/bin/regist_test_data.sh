#!/bin/sh
DB_DIR=/var/ocdet/testresult.db
OCDET_DIR=/var/ocdet/
OCDET_BINDIR=/opt/ocdet/bin
PREV_TIME=$LC_TIME

PREV_MESSAAGES=$LC_LC_MESSAGES
export LC_MESSAGES=C
export LC_TIME=C
python $OCDET_BINDIR/711_regist_test_data.py $1 $DB_DIR $OCDET_DIR
export LC_MESSAGES=$PREV_MESSAAGES
export LC_TIME=$PREV_TIME

