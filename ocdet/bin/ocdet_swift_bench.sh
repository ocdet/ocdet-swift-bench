#!/bin/bash 

export PATH=$PATH:/opt/ocdet/bin
export OCDET_SWIFT_CONFIG_DIR=/etc/swift/

export OCDET_KEY=ocdet2012
export PROXY_AUTH_USER=ocdet:ocdet
export PROXY_AUTH_KEY=ocdet2012
export SWIFT_DIR=/swift # 特に変更しないけど一応変数に
export OCDET_DEVICE_PREFIX=ocdet
export OCDET_PART_POWER=10
export OCDET_CAPISTRANO=/opt/ocdet/capistrano

OCDET_TEST_PARAM=$1
export OCDET_TEST_START=`date +%s`
export OCDET_TESTID=$OCDET_TEST_START-$OCDET_TEST_PARAM
#sudo rm -rf /var/ocdet/13*
export OCDET_BASEDIR=/var/ocdet/$OCDET_TESTID
sudo mkdir -p $OCDET_BASEDIR
sudo chmod 777 $OCDET_BASEDIR

date +%s >> $OCDET_BASEDIR/start_time

export ROLE_SERVERS=/opt/ocdet/role_servers.txt   # サーバの役割とアドレス一覧
export TEMP_ROLE_FILE=${OCDET_BASEDIR}/role.rb    # ↑をCapistrano用に変換したファイル

export MEMCACHE_SERVERS=127.0.0.1:11211
export KEYSTONE_ENDPOINT=127.0.0.1

export OCDET_BENCH_RESULT=0
export OCDET_SWIFT_BENCH_LOG=ocdet-swift-bench.log.$OCDET_TESTID
#echo $OCDET_TESTID >> log/$OCDET_SWIFT_BENCH_LOG

# 変数定義
## サーバパラメータ
#PROXY_WORKERS=8
#OBJECT_WORKERS=8
#CONTAINER_WORKERS=8
#ACCOUNT_WORKERS=8
#REPLICATION=3
#ZONE=3
#(ZONE>=REPLICATION)
#OBJECT_PAR_ZONE=1
#CONTAINER_PAR_ZONE=1
#ACCOUNT_PAR_ZONE=1
#PROXY_NUM=4
#PROXY_AUTH_METHOD=tempauth
#PROXY_CACHE=on # 変更できないようなので設定不要
#DOWN_ZONE=0
#OCDET_KEY=ocdet

## クライアントパラメータ
#OBJECT_SIZE=1024
#NUM_GETS=10
#NUM_PUTS=10
# OBJECT_SIZE*NUM_GETS は常に一定になるように調整
# またNUM_PUTS == NUM_GETS
#CONCURRENCY=10
#SWIFT_BENCH_WORKERS=4
#NUM_CONTAINERS=20

#SWIFT_BENCH_NUM=4
#CONNECT_PROXY_NUM=4 廃止の方向で
# 現行だと PROXY_NUM = CONNECT_PROXY_NUM
# CONNECT_PROXY_NUM 廃止の方向で行きます。


# 引数処理


export PROXY_WORKERS=`echo $OCDET_TEST_PARAM | cut -d- -f 1`
export OBJECT_WORKERS=`echo $OCDET_TEST_PARAM | cut -d- -f 2`
export CONTAINER_WORKERS=`echo $OCDET_TEST_PARAM | cut -d- -f 3`
export ACCOUNT_WORKERS=`echo $OCDET_TEST_PARAM | cut -d- -f 4`
export REPLICATION=`echo $OCDET_TEST_PARAM | cut -d- -f 5`
export ZONE=`echo $OCDET_TEST_PARAM | cut -d- -f 6`
#(ZONE>=REPLICATION)
# To 松井さん HOST_PAR_ZONE をaccount, container, object へ分割します。
# export HOST_PAR_ZONE=`echo $OCDET_TEST_PARAM | cut -d- -f 7`
export ACCOUNT_PAR_ZONE=`echo $OCDET_TEST_PARAM | cut -d- -f 7`
export CONTAINER_PAR_ZONE=`echo $OCDET_TEST_PARAM | cut -d- -f 8`
export OBJECT_PAR_ZONE=`echo $OCDET_TEST_PARAM | cut -d- -f 9`
export PROXY_NUM=`echo $OCDET_TEST_PARAM | cut -d- -f 10`
export PROXY_AUTH_METHOD=`echo $OCDET_TEST_PARAM | cut -d- -f 11`
export PROXY_CACHE=`echo $OCDET_TEST_PARAM | cut -d- -f 12`
export DOWN_ZONE=`echo $OCDET_TEST_PARAM | cut -d- -f 13`
export OBJECT_SIZE=`echo $OCDET_TEST_PARAM | cut -d- -f 14`
export NUM_GETS=`echo $OCDET_TEST_PARAM | cut -d- -f 15`
export NUM_PUTS=`echo $OCDET_TEST_PARAM | cut -d- -f 16`
export CONCURRENCY=`echo $OCDET_TEST_PARAM | cut -d- -f 17`
export SWIFT_BENCH_NUM=`echo $OCDET_TEST_PARAM | cut -d- -f 18`
export NUM_CONTAINERS=`echo $OCDET_TEST_PARAM | cut -d- -f 19`
# 現行だと PROXY_NUM = $SWIFT_BENCH_NUM、後ろ2つはSWIFT_BENCH_WORKERSで良いため不要.
# 変数名の精査は次の段階まで保留


# Capistrano用のroleファイルを生成
001_generate_capis_role.sh
if [ $? != 0 ]; then
   echo "Error: 001_generate_capis_role.sh"
   exit 1
fi

# 実験前のクリーンアップ
010_swift_stop.sh
if [ $? != 0 ]; then
   echo "Error: 010_swift_stop.sh"
   exit 1
fi

cd $OCDET_CAPISTRANO
cap test_swift_stop
if [ $? != 0 ]; then
   echo "Error: 010_swift_stop test failed"
   exit 1
fi

015_sar_stop.sh
if [ $? != 0 ]; then
   echo "Error: 030_sar_stop.sh"
   exit 1
fi

cd $OCDET_CAPISTRANO
cap test_sar_stop
if [ $? != 0 ]; then
   echo "Error: 015_sar_stop test failed"
   exit 1
fi

020_cleanup_all.sh
if [ $? != 0 ]; then
   echo "Error: 020_cleanup_all.sh"
   exit 1
fi

cd $OCDET_CAPISTRANO
cap test_cleanup_all
if [ $? != 0 ]; then
   echo "Error: 020_cleanup_all.sh test failed"
   exit 1
fi

# 設定ファイルの作成
110_generate_configs.sh 
if [ $? != 0 ]; then
   echo "Error: 110_generate_configs.sh "
   exit 1
fi

cd /opt/autotest/110_generate_configs ; rake spec
if [ $? != 0 ]; then
   echo "Error: 110_generate_configs.sh test failed"
   exit 1
fi

111_generate_object_config.sh
if [ $? != 0 ]; then
   echo "Error: 111_generate_object_config.sh"
   exit 1
fi

cd /opt/autotest/111_generate_object_config ; rake spec
if [ $? != 0 ]; then
   echo "Error: 111_generate_object_config test failed"
   exit 1
fi

112_generate_container_config.sh
if [ $? != 0 ]; then
   echo "Error: 112_generate_container_config.sh"
   exit 1
fi

cd /opt/autotest/112_generate_container_config ; rake spec
if [ $? != 0 ]; then
   echo "Error: 112_generate_container_config test failed"
   exit 1
fi

113_generate_account_config.sh
if [ $? != 0 ]; then
   echo "Error: 113_generate_account_config.sh"
   exit 1
fi

cd /opt/autotest/113_generate_account_config ; rake spec
if [ $? != 0 ]; then
   echo "Error: 113_generate_account_config test failed"
   exit 1
fi

114_generate_proxy_config.sh
if [ $? != 0 ]; then
   echo "Error: 114_generate_proxy_config.sh"
   exit 1
fi

cd /opt/autotest/114_generate_proxy_config ; rake spec
if [ $? != 0 ]; then
   echo "Error: 114_generate_proxy_config test failed"
   exit 1
fi

#115_generate_rsyncd_config.sh -d $SWIFT_DIR
120_generate_rings.sh
if [ $? != 0 ]; then
   echo "Error: 120_generate_rings.sh"
   exit 1
fi

130_generate_bench.sh
if [ $? != 0 ]; then
   echo "Error: 130_generate_bench.sh"
   exit 1
fi


# 設定ファイルの配布・反映
210_put_configs.sh
if [ $? != 0 ]; then
   echo "Error: 210_put_configs.sh"
   exit 1
fi

220_put_rings.sh
if [ $? != 0 ]; then
   echo "Error: 220_put_rings.sh"
   exit 1
fi

230_put_bench.sh
if [ $? != 0 ]; then
   echo "Error: 230_put_bench.sh"
   exit 1
fi


# Swift・sar起動
310_start_proxy.sh
if [ $? != 0 ]; then
   echo "Error: 310_start_proxy.sh"
   exit 1
fi

320_start_account.sh
if [ $? != 0 ]; then
   echo "Error: 320_start_account.sh"
   exit 1
fi

330_start_container.sh
if [ $? != 0 ]; then
   echo "Error: 330_start_container.sh"
   exit 1
fi

340_start_object.sh
if [ $? != 0 ]; then
   echo "Error: 340_start_object.sh"
   exit 1
fi

350_check_swift.sh
if [ $? != 0 ]; then
   echo "Error: 350_check_swift.sh"
   exit 1
fi

360_sar_start.sh
if [ $? != 0 ]; then
   echo "Error: 360_sar_start.sh"
   exit 1
fi


# swift-benchの実行
410_start_bench.sh
if [ $? != 0 ]; then
   430_sar_stop.sh
   echo "Error: 410_start_bench.sh"
   exit 1
fi

420_wait_bench.sh
if [ $? != 0 ]; then
   430_sar_stop.sh
   echo "Error: 420_wait_bench.sh"
   exit 1
fi

430_sar_stop.sh
if [ $? != 0 ]; then
   echo "Error: 430_sar_stop.sh"
   exit 1
fi


# Swiftの停止
#510_stop_proxy.sh
if [ $? != 0 ]; then
   echo "Error: 510_stop_proxy.sh"
   exit 1
fi

#520_stop_account.sh
if [ $? != 0 ]; then
   echo "Error: 520_stop_account.sh"
   exit 1
fi

#530_stop_container.sh
if [ $? != 0 ]; then
   echo "Error: 530_stop_container.sh"
   exit 1
fi

#540_stop_object.sh
if [ $? != 0 ]; then
   echo "Error: 540_stop_object.sh"
   exit 1
fi


# 結果の収集
610_collect_result.sh
if [ $? != 0 ]; then
   echo "Error: 610_collect_result.sh"
   exit 1
fi


# 実験結果
710_write_result.sh
if [ $? != 0 ]; then
   echo "Error: 710_write_result.sh"
   exit 0
fi

date +%s >> $OCDET_BASEDIR/end_time
