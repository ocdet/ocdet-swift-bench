ocdet-swift-bench
=================

benchmark automation scripts for openstack swift

このプログラムはOCDETの活動で
OpenStack Swiftの大規模ベンチマークを実施した際に使用した
スクリプト集となります。

ベンチマークパラメータとして(引数で)
Objectのサイズや並列数から、各サーバの台数等を含めて指定して
実行すると、環境構築からベンチマークの実行・ログの取得までを
全て自動で行なってくれるスクリプトとなります。

ただし、2013/08/31にベンチマークを取得して以来、
スクリプトの改修をしておらず、未実装のままとなっている箇所も残っています。
過度な期待はしないでください。

=================

ファイル・ディレクトリ一覧

・autotest

各ノードからNFS mountして利用します。
(チェック用のスクリプトやfstab情報があります。)

・ocdet

capistranoやスクリプト用のディレクトリがあります。

・ocdet/bin

ベンチマークスクリプト本体(ocdet_swift_bench.sh)及び
本体から呼び出しているスクリプトがあります。

・ocdet/capistrano

capistrano用のスクリプトです。

・ocdet/role_servers.txt

ベンチマークを行なうためのサーバリストを定義するファイルとなります。
