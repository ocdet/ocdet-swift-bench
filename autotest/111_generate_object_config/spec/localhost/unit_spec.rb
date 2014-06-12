require 'spec_helper'

swift_dir=ENV["SWIFT_DIR"]
object_workers=ENV["OBJECT_WORKERS"]
ocdet_basedir=ENV["OCDET_BASEDIR"]

describe command("grep devices #{ocdet_basedir}//object-server.conf") do
  it { should return_stdout /#{swift_dir}/ }
end

describe command('env | grep OBJECT_WORKERS') do
  it { should return_exit_status 0 }
end

describe command("grep workers #{ocdet_basedir}/object-server.conf") do
  it { should return_stdout /#{object_workers}/ }
end
