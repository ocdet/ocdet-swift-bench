#!/bin/bash -x

# -z zone
# -r replication
# ZONE >= REPLICATION
# -n node
# -l list

ring_build ()
{
 TYPE=$1
 TYPE_NUM=$2
 TYPE_PAR_ZONE=$3
 TYPE_PORT=$4
 OUTPUT_FILE=${TYPE}.builder

 swift-ring-builder $OUTPUT_FILE create $OCDET_PART_POWER $REPLICATION 1
 z=1
 tmp=0
 count=1
 for n in `egrep "storage|$TYPE" $ROLE_SERVERS | cut -d, -f 2 | head -$TYPE_NUM`
 do
  swift-ring-builder $TYPE.builder add z$z-$n:$TYPE_PORT/$OCDET_DEVICE_PREFIX 1
  tmp=`expr $count % $TYPE_PAR_ZONE`
  if [ $tmp -eq 0 ] ; then
   z=`expr 1 + $z`
  fi
  count=`expr $count + 1`
 done
 swift-ring-builder $OUTPUT_FILE rebalance

 if [ ! -f "$OUTPUT_FILE" ]
 then
  echo "file $OUTPUT_FILE not exist"
  exit 1
 fi

 if [ ! -s "$OUTPUT_FILE" ]
 then
  echo "file $OUTPUT_FILE size zero"
  exit 1
 fi

}

echo "----- ${0##*/} -----"

## 必須変数チェック
echo "REPLICATION:       " ${REPLICATION:?"is not set"}
echo "ZONE:       " ${ZONE:?"is not set"}
echo "OBJECT_PAR_ZONE:       " ${OBJECT_PAR_ZONE:?"is not set"}
echo "CONTAINER_PAR_ZONE:       " ${CONTAINER_PAR_ZONE:?"is not set"}
echo "ACCOUNT_PAR_ZONE:       " ${ACCOUNT_PAR_ZONE:?"is not set"}
echo "OCDET_DEVICE_PREFIX:       " ${OCDET_DEVICE_PREFIX:?"is not set"}
echo "OCDET_BASEDIR:       " ${OCDET_BASEDIR:?"is not set"}
echo "OCDET_PART_POWER:       " ${OCDET_PART_POWER:?"is not set"}
echo "ROLE_SERVERS:       " ${ROLE_SERVERS:?"is not set"}

OBJECT_NUM=`expr $OBJECT_PAR_ZONE \* $ZONE`
CONTAINER_NUM=`expr $CONTAINER_PAR_ZONE \* $ZONE`
ACCOUNT_NUM=`expr $ACCOUNT_PAR_ZONE \* $ZONE`
#totalnodes=`expr $OBJECT_NODES + $CONTAINER_NODES + $ACCOUNT_NODES`
echo $totalnodes

#listnodes=`wc -l $ROLE_SERVERS | awk '{print $1}' | sed -d 's/[^0-9]//g'`
LIST_OBJS=`grep object $ROLE_SERVERS | wc -l | awk '{print $1}'`
LIST_CNTS=`grep container $ROLE_SERVERS | wc -l | awk '{print $1}'`
LIST_ACCS=`grep account $ROLE_SERVERS | wc -l | awk '{print $1}'`

#if [ "$totalnodes" -lt "$listnodes" ]
#then
#        echo "total node is not enough" 1>&2
#	echo "total nodes is $totalnodes, node list is $listnodes"
#
#        exit 1
#fi

if [ "$ZONE" -lt "$REPLICATION" ]
then
        echo "zone must be equal or big more than replication!" 1>&2
	echo "(ZONE is $ZONE, REPLICATION is $REPLICATION)"
        exit 1
fi

if [ "$OBJECT_NUM" -gt "$LIST_OBJS" ]
then
        echo "object node is not enough" 1>&2
        exit 1
fi

if [ "$CONTAINER_NUM" -gt "$LIST_CNTS" ]
then
        echo "container node is not enough" 1>&2
        exit 1
fi

if [ "$ACCOUNT_NUM" -gt "$LIST_ACCS" ]
then
        echo "account node is not enough" 1>&2
        exit 1
fi

# object ring build

cd $OCDET_BASEDIR

ring_build object $OBJECT_NUM $OBJECT_PAR_ZONE 6000
ring_build container $CONTAINER_NUM $CONTAINER_PAR_ZONE 6001
ring_build account $ACCOUNT_NUM $ACCOUNT_PAR_ZONE 6002

exit 0
