require 'spec_helper'

## ファイルの存在チェック

describe file('/etc/swift/account.builder') do
  it { should be_file }
end

describe file('/etc/swift/container.builder') do
  it { should be_file }
end

describe file('/etc/swift/object.builder') do
  it { should be_file }
end

describe file('/etc/swift/account.ring.gz') do
  it { should be_file }
end

describe file('/etc/swift/container.ring.gz') do
  it { should be_file }
end

describe file('/etc/swift/object.ring.gz') do
  it { should be_file }
end

