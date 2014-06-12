require 'spec_helper'

ocdet_key=ENV["OCDET_KEY"]
ocdet_basedir=ENV["OCDET_BASEDIR"]

describe command('env | grep OCDET_KEY') do
  it { should return_exit_status 0 }
end

describe command('env | grep OCDET_BASEDIR') do
  it { should return_exit_status 0 }
end

describe command("grep swift_hash_path_suffix #{ocdet_basedir}/swift.conf") do
  it { should return_stdout /#{ocdet_key}/ }
end
