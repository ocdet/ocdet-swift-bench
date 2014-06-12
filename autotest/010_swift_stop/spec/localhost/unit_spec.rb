require 'spec_helper'

## ポートがLISTENしていないことを確認

describe port(8080) do
  it { should_not be_listening }
end

describe port(6000) do
  it { should_not be_listening }
end

describe port(6001) do
  it { should_not be_listening }
end

describe port(6002) do
  it { should_not be_listening }
end


## プロセスの停止を確認

describe command('ps -ef |grep -v grep |grep swift-proxy-') do
  it { should_not return_exit_status 0 }
end

describe command('ps -ef |grep -v grep |grep swift-account-') do
  it { should_not return_exit_status 0 }
end

describe command('ps -ef |grep -v grep |grep swift-container-') do
  it { should_not return_exit_status 0 }
end

describe command('ps -ef |grep -v grep |grep swift-object-') do
  it { should_not return_exit_status 0 }
end

