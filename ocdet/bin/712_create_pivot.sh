#!/bin/sh -x

if [ -z "$OCDET_TESTID" ]; then
  if [ -z "$1" ]; then
    echo $0 TESTID
    exit 1
  fi
  OCDET_TESTID=$1
fi

OCDET_BASEDIR=/var/ocdet/$OCDET_TESTID
OCDET_PERFDB_PATH=/var/ocdet/testresult.db
OCDET_BINDIR=/opt/ocdet/bin

#convert sqlite data to text files.

#IO
echo "select hostname , recordtime , BREADPS/2  , BWRTNPS/2  from IO n , host h , test t where n.hostid = h.hostid and testname = '$OCDET_TESTID' and n.testid = t.testid order by hostname  ,recordtime;"  | sqlite3 $OCDET_PERFDB_PATH > $OCDET_BASEDIR/io.txt 

#format text files to pivot csv files
python $OCDET_BINDIR/FormIO.py $OCDET_BASEDIR/io.txt > $OCDET_BASEDIR/io.csv

#Network 
echo "select hostname , iface , recordtime , rxkbps , txkbps from network n , host h , test t where n.hostid = h.hostid and testname =  '$OCDET_TESTID' and n.testid = t.testid order by hostname  ,recordtime;" | sqlite3 $OCDET_PERFDB_PATH > $OCDET_BASEDIR/network.txt

#format text files to pivot csv files
python $OCDET_BINDIR/FormNetwork.py $OCDET_BASEDIR/network.txt > $OCDET_BASEDIR/network.csv

#CPU
echo "select hostname , recordtime , PUSER , PSYSTEM, PIOWAIT , PSTEAL , PIDLE from cpu n , host h , test t where n.hostid = h.hostid and testname =  '$OCDET_TESTID' and n.testid = t.testid and n.CPU = 'all' order by hostname  ,recordtime;" | sqlite3 $OCDET_PERFDB_PATH > $OCDET_BASEDIR/cpu.txt

#format text files to pivot csv files
python $OCDET_BINDIR/FormCPU.py $OCDET_BASEDIR/cpu.txt > $OCDET_BASEDIR/cpu.csv






