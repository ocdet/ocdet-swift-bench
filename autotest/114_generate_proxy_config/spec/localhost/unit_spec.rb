require 'spec_helper'

proxy_auth_method=ENV["PROXY_AUTH_METHOD"]
memcache_servers=ENV["MEMCACHE_SERVERS"]
keystone_endpoint=ENV["KEYSTONE_ENDPOINT"]
proxy_workers=ENV["PROXY_WORKERS"]
proxy_auth_user=ENV["PROXY_AUTH_USER"]
proxy_auth_key=ENV["PROXY_AUTH_KEY"]
ocdet_basedir=ENV["OCDET_BASEDIR"]

describe command("grep pipeline #{ocdet_basedir}/proxy-server.conf") do
  it { should return_stdout /#{proxy_auth_method}/ }
end

describe command("grep memcache_servers #{ocdet_basedir}/proxy-server.conf") do
  it { should return_stdout /#{memcache_servers}/ }
end

describe command("grep auth_uri #{ocdet_basedir}/proxy-server.conf") do
  it { should return_stdout /#{keystone_endpoint}/ }
end

describe command("grep workers #{ocdet_basedir}/proxy-server.conf") do
  it { should return_stdout /#{proxy_workers}/ }
end

describe command("grep user #{ocdet_basedir}/proxy-server.conf | sed s/_/:/g") do
  it { should return_stdout /#{proxy_auth_user}/ }
end

describe command("grep user #{ocdet_basedir}/proxy-server.conf") do
  it { should return_stdout /#{proxy_auth_key}/ }
end

