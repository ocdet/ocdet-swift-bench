require 'spec_helper'


#base_dir = "#{ENV["OCDET_BASEDIR"]}"
#load "#{ENV["OCDET_BASEDIR"]}/role.rb"
load "/opt/autotest/role_test/spec/localhost/role.rb"

lbhosts = Array::new
 roles[:proxy].each {|item| lbhosts.push(item.host)}

print lbhosts.join(',')
