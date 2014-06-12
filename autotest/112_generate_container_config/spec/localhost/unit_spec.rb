require 'spec_helper'

swift_dir=ENV["SWIFT_DIR"]
container_workers=ENV["CONTAINER_WORKERS"]
ocdet_basedir=ENV["OCDET_BASEDIR"]

describe command('env | grep CONTAINER_WORKERS') do
  it { should return_exit_status 0 }
end

describe command("grep devices #{ocdet_basedir}/swift/container-server.conf") do
  it { should return_stdout /#{swift_dir}/ }
end

describe command("grep workers #{ocdet_basedir}/container-server.conf") do
  it { should return_stdout /#{container_workers}/ }
end
