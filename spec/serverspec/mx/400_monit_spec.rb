# frozen_string_literal: true

require_relative "../spec_helper"
require "shellwords"

monitored_services = %w[sshd nsd check_nsd_ns]

describe service "monit" do
  it { should be_running }
  it { should be_enabled }
end

monitored_services.each do |service|
  # XXX use cat(1) to disable color in output
  describe command "monit status #{Shellwords.escape(service)} | cat -" do
    its(:stderr) { should eq "" }
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/^\s+status\s+(?:OK|Initializing)/) }
    its(:stdout) { should match(/^\s+monitoring status\s+(?:Waiting|Monitored|Initializing)/) }
  end
end
