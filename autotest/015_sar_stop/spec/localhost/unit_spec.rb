require 'spec_helper'

## プロセスの停止を確認

describe command('ps -ef |grep -v grep |grep "sar -A -o"') do
  it { should_not return_exit_status 0 }
end


