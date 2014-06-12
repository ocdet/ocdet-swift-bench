require 'spec_helper'

swift_dir=ENV["SWIFT_DIR"]
account_workers=ENV["ACCOUNT_WORKERS"]
ocdet_basedir=ENV["OCDET_BASEDIR"]

describe command('env | grep ACCOUNT_WORKERS') do
  it { should return_exit_status 0 }
end

describe command("grep devices #{ocdet_basedir}/account-server.conf") do
  it { should return_stdout /#{swift_dir}/ }
end

describe command("grep workers #{ocdet_basedir}/account-server.conf") do
  it { should return_stdout /#{account_workers}/ }
end
