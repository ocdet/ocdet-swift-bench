#!/bin/bash

echo "----- ${0##*/} -----"

## 必須変数のチェック
echo "OCDET_KEY:       " ${OCDET_KEY:?"is not set"}
echo "OCDET_BASEDIR:       " ${OCDET_BASEDIR:?"is not set"}

OUTPUT_FILE=swift.conf

cd $OCDET_BASEDIR

echo "
[swift-hash]
# random unique string that can never change (DO NOT LOSE)
swift_hash_path_suffix = $OCDET_KEY
" > $OUTPUT_FILE

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

exit 0

