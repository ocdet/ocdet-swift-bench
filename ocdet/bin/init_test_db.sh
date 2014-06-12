#!/bin/sh
OCDET_PERFDB_PATH=/var/ocdet/testresult.db
CREATEDB=/opt/ocdet/capistrano/utils/create_table.sql
# create tables

echo .read $CREATEDB | sqlite3 $OCDET_PERFDB_PATH
