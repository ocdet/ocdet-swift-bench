# -*- coding: utf-8 -*-
set :max_hosts, 5
set :application, "OCDET swift"

SCRIPTTEXT = <<EOS
#!/bin/sh
MYHOST=$1
SCRIPT_BODY  
EOS

IFENTRY = <<EOSS
if [ $MYHOST = "GENERATOR" ]; then 
  TARGET_PROXY_ADDRESS=BALANCER
fi

EOSS

install_dir = "/tmp/#{ENV["OCDET_TESTID"]}"
script_dir = "./scripts"
config_dir = "./config"
base_dir = "#{ENV["OCDET_BASEDIR"]}"
load "#{ENV["OCDET_BASEDIR"]}/role.rb"

#  require 'pry'
#  binding.pry

# load balancerとload generatorのマッピングをおこなうshell scriptの作成
def create_find_target_proxy(out_dir)

  lbhosts = Array::new
  roles[:proxy].each {|item| lbhosts.push(item.host)}

  body = ""
  index = 0;
  roles[:load_generator].each { |item| 
    body << IFENTRY.gsub(/GENERATOR/,item.host).gsub(/BALANCER/,lbhosts[index%lbhosts.size])
    index += 1
  }

  open(out_dir+"/find_target_proxy.sh","w+") { |file|
    file.write(SCRIPTTEXT.gsub(/SCRIPT_BODY/,body))
  }

end

#ファイルをターゲットサーバにおいてろsudo実行
def execute_file_as_root (file)
  install_dir = "/tmp/#{ENV["OCDET_TESTID"]}"
  script_dir = "./scripts"
  run "mkdir -p #{install_dir}"
  sudo "chmod 0777 #{install_dir}"
  upload(script_dir+"/"+file, install_dir+"/"+file, :via => :scp)
  run "#{sudo} sh #{install_dir}/#{file}"
end

# 確認用タスク
task :mytest do
  #execute_file_as_root("test.sh")
  require 'pry'
  require 'socket'
  p Socket.gethostname
#  binding.pry
  
end

# Folsom版swiftインストール
task :install_folsom_swift, :roles => [:work] do
  execute_file_as_root("install_folsom.sh")
end

# Folsom版swiftアンインストール
task :uninstall_folsom_swift, :roles => [:work]  do
  execute_file_as_root("uninstall_folsom.sh")   
end

# Essex版swiftインストール
task :install_essex_swift, :roles => [:work] do
  execute_file_as_root("install.sh")   
end

# Essex版swiftアンインストール
task :uninstall_essex_swift, :roles => [:work] do
  execute_file_as_root("uninstall.sh")   
end

# rysnc設定コピー
task :put_rsync_config, :roles => [:work]  do
  execute_file_as_root("put_rsync_config.sh")
end


# Swiftユーザ作成
task :create_user, :roles => [:work] do
  execute_file_as_root("create_user.sh")
end

# Swiftユーザ削除
task :delete_user, :roles => [:work] do
  execute_file_as_root("delete_user.sh")   
end

# Swift ファイルシステム作成
task :make_filesystem , :roles => [:work]   do
  execute_file_as_root("make_filesystem.sh")
end

# Swift ファイルシステム削除
task :delete_filesystem , :roles => [:work]  do
  execute_file_as_root("delete_filesystem.sh")
end

# Swiftサービス起動
task :start_service ,:roles => [:account,:object,:container,:proxy]  do
  run "#{sudo} swift-init all start"
end

# Memcacheサービス起動
task :start_memcache ,:roles => [:proxy]  do         
  run "#{sudo} service memcached start"
end  

# Swiftサービス停止
task :stop_service ,:roles => [:all]  do
  run "#{sudo} swift-init all stop"
end

# Swiftサービスチェック
task :check_swift , :roles => [:account,:object,:container,:proxy] do
  run "#{sudo} curl -v -H 'X-Storage-User: test:tester' -H 'X-Storage-Pass: testing' http://$CAPISTRANO:HOST$:8080/auth/v1.0"
end

# Swift削除
task :cleanup_all ,:roles => [:all] do 
#  target_dir = #{ENV[SWIFT_DIR]/$ENV[OCDET_DEVICE_PREFIX]}"
#  if target_dir != nil && target_dir != "/" then
#    run "#{sudo} mv #{target_dir}  #{target_dir}_old "
#    run "#{sudo} rm -rf #{target_dir}_old"
    run "#{sudo} rm -rf /etc/swift/*"
    run "#{sudo} umount -f /swift; echo dummy"
# for physdisk
#    run "#{sudo} mkfs.xfs -i size=1024 -f /dev/sdb"
#    run "#{sudo} mount /dev/sdb /swift"  

# for ramdisk
    run "#{sudo} umount -f /mnt/temp ; echo umount tempfs"
    run "#{sudo} mkdir -p /mnt/temp"
    run "#{sudo} mount -t tmpfs -o size=5g /dev/shm /mnt/temp/"
    run "#{sudo} dd if=/dev/zero of=/mnt/temp/disk.img bs=1024k count=1 seek=4095"
    run "#{sudo} mkfs.xfs -i size=1024 -f /mnt/temp/disk.img"
    run "#{sudo} mount -t xfs -o loop /mnt/temp/disk.img /swift"


    run "#{sudo} mkdir -p /swift/ocdet"
    run "#{sudo} chown -R swift:swift /swift"
    run "#{sudo} service memcached restart"
#  end
end

# Sar起動
task :start_sar , :roles => [:work] do
  file = "start_ocdet_sar.sh"
  install_dir = "/tmp/#{ENV["OCDET_TESTID"]}"
  script_dir = "./scripts"
  run "mkdir -p #{install_dir}"
  sudo "chmod 0777 #{install_dir}"
  upload(script_dir+"/"+file, install_dir+"/"+file, :via => :scp)
  run "#{sudo} sh #{install_dir}/#{file} #{install_dir}/host.sar"
end

# Sar停止
task :stop_sar , :roles => [:all] do
  execute_file_as_root("stop_ocdet_sar.sh")
end

# Sar結果取得
task :get_sar_results , :roles => [:work] do
  download("#{install_dir}/host.sar","#{base_dir}/$CAPISTRANO:HOST$.sar", :via => :scp)  
end

# Sarの起動確認
task :status_sar , :roles => [:work] do
  begin
    run "ps -ef | grep sar | grep -v grep"
  rescue
    p "no running process"
  end
  run "ls -l #{install_dir}/sar_result"
end

# Swift設定ファイル配置
task :put_configs ,:roles => [:work]  do

  files=["swift.conf",
         "proxy-server.conf",
         "account-server.conf",
         "container-server.conf", 
         "object-server.conf",
	]
  #for debug
  #sudo "rm -rf  /tmp/13*"

  run "mkdir -p #{install_dir}"
  files.each { |file|
    upload(base_dir+"/"+file,install_dir+"/"+file, :via => :scp)
    sudo "cp -f #{install_dir}/#{file} /etc/swift/#{file}"
  }
  sudo "chmod 0644 /etc/swift/*.conf"
  files.each { |file|
    sudo "ls /etc/swift/#{file}"
  }
  
  sudo "sed -i -e 's/bind_ip = 0.0.0.0/bind_ip = $CAPISTRANO:HOST$/' /etc/swift/proxy-server.conf"
  sudo "sed -i -e 's/bind_ip = 192.168.10/bind_ip = 192.168.20/' /etc/swift/proxy-server.conf"
end

# Ringファイル配置
task :put_rings ,:roles => [:work]  do
  files=["account.ring.gz",
         "object.ring.gz",
         "container.ring.gz",
	]
  run "mkdir -p #{install_dir}"
  files.each { |file|                                                                      
    upload(base_dir+"/"+file,install_dir+"/"+file, :via => :scp)
    sudo "cp -f #{install_dir}/#{file} /etc/swift/#{file}"
  }                                                                                        
  sudo "chmod 0644 /etc/swift/*.gz"   
  files.each { |file|
    sudo "ls /etc/swift/#{file}"
  }
end

# ベンチマーク配置
task :put_benches ,:roles => [:load_generator] do
  files=["swift-bench.sh",
         "find_target_proxy.sh"
        ]                                                                                  

  create_find_target_proxy(base_dir)
  files.each { |file|
    upload(base_dir+"/"+file,install_dir+"/"+file, :via => :scp)
  }                                                                                        
  run "chmod 0755 #{install_dir}/swift-bench.sh"
end

# ベンチマーク実行
task :run_bench  ,:roles => [:load_generator] do
  run "#{install_dir}/swift-bench.sh > $CAPISTRANO:HOST$_#{ENV["OCDET_TESTID"]}.swift-bench.result 2>&1"
end


# ベンチマーク結果取得
task :get_bench_results , :roles => [:load_generator] do
  filename = "$CAPISTRANO:HOST$_#{ENV["OCDET_TESTID"]}.swift-bench.result"
  download(filename,"#{base_dir}/$CAPISTRANO:HOST$.swift-bench.result", :via => :scp)
end      


task :start_swift ,:roles => [:account,:object,:container,:proxy]  do
  sudo "swift-init #{_agent_type} start"
end

task :swift_started ,:roles => [:account,:object,:container,:proxy]  do
  run "ps -ef | cut -f 1 -d ' ' | grep swift; test $? -eq 0"
end

task :swift_stopped ,:roles => [:all]  do
  run "ps -ef | cut -f 1 -d ' ' | grep swift; test $? -eq 1"
end

task :stop_swift ,:roles => [:account,:object,:container,:proxy]  do
  sudo "swift-init #{_agent_type} stop"
end

task :copy_ssh_key , :roles => [:work] do
  upload("#{ENV["HOME"]}/.ssh/id_rsa.pub","id_rsa.pub", :via => :scp)
  upload("#{ENV["HOME"]}/.ssh/id_rsa","id_rsa", :via => :scp)
  upload("#{ENV["HOME"]}/.ssh/authorized_keys","authorized_keys", :via => :scp)
  run "if [ ! -d \"$HOME/.ssh\" ]; then mkdir $HOME/.ssh;chmod 0700 $HOME/.ssh ; fi"
  run "mv id_rsa .ssh/"
  run "mv id_rsa.pub .ssh/"
  run "mv authorized_keys .ssh/"
  run "chmod 0644 .ssh/* ; chmod 0600 .ssh/id_rsa"
end

task :add_sudoers , :roles => [:work] do
  execute_file_as_root("add_sudoers.sh")
end

task :install_essex , :roles => [:work] do
  create_user
  install_essex_swift
  make_filesystem
end

task :install_folsom , :roles => [:work] do
  create_user
  install_folsom_swift
  make_filesystem
end

# Install Server spec
task :install_serverspec ,:roles => [:work] do
  sudo "yum install -y ruby ruby-devel rubygems rubygem-rake"
  sudo "rm -rf /root/temp "
  sudo "mkdir /root/temp"
  sudo "cd /root/temp"
  sudo "wget --no-check-certificate https://kvps-27-34-160-192.secure.ne.jp/pub/serverspec.rpm.tgz"
  sudo "tar zxvf serverspec.rpm.tgz"
  sudo "rpm -ihv *.rpm"
end

task :test_swift_stop , :roles => [:all] do
  run "cd /opt/autotest/010_swift_stop/ ; rake spec"
end

task :test_sar_stop , :roles => [:all] do
  run "cd /opt/autotest/015_sar_stop/ ; rake spec"
end

task :test_cleanup_all , :roles => [:all] do
  run "cd /opt/autotest/020_cleanup_all/ ; rake spec"
end

task :test_put_configs , :roles => [:work]  do
  run "cd /opt/autotest/210_put_configs/ ; rake spec"
end

