require 'spec_helper'

## ファイルの存在チェック

describe file('/etc/swift/account-server.conf') do
  it { should be_file }
end

describe file('/etc/swift/container-server.conf') do
  it { should be_file }
end

describe file('/etc/swift/object-server.conf') do
  it { should be_file }
end

describe file('/etc/swift/proxy-server.conf') do
  it { should be_file }
end

describe file('/etc/swift/swift.conf') do
  it { should be_file }
end

describe file('/etc/swift/role_servers.txt') do
  it { should be_file }
end


