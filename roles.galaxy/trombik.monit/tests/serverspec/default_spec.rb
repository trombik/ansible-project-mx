require "spec_helper"
require "serverspec"

package = "monit"
service = "monit"
config  = "/etc/monitrc"
config_dir = "/etc/monit.d"
ports = [2812]
script_dir = "/etc/monit.script"
ssh_rc_command = {
  start: "",
  stop: ""
}
default_user = "root"
default_group = "root"
extra_include_dir = "/usr/local/project/config/monit"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/monitrc"
  config_dir = "/usr/local/etc/monit.d"
  ssh_rc_command = { start: "service sshd start", stop: "service sshd stop" }
  default_group = "wheel"
  script_dir = "/usr/local/etc/monit.script"
when "openbsd"
  ssh_rc_command = { start: "rcctl start sshd", stop: "rcctl stop sshd" }
  default_group = "wheel"
  script_dir = "/etc/monit.script"
when "ubuntu"
  config = "/etc/monit/monitrc"
  config_dir = "/etc/monit/monitrc.d"
  ssh_rc_command = { start: "service ssh start", stop: "service ssh stop" }
  script_dir = "/etc/monit/monit.script"
when "redhat"
  ssh_rc_command = { start: "/bin/systemctl start sshd", stop: "/bin/systemctl stop sshd" }
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 600 }
  its(:content) { should match(/^set daemon \d+\n\s+with start delay \d+/) }
  its(:content) { should match(/^set httpd port 2812\n\s+use address #{ Regexp.escape('127.0.0.1') }\n\s+allow\s+#{ Regexp.escape('127.0.0.1') }/) }
  its(:content) { should match(/^set logfile syslog facility log_daemon/) }
  its(:content) { should match(/^include #{ Regexp.escape(config_dir + '/*.monitrc') }/) }
  its(:content) { should match(/^include #{ Regexp.escape(extra_include_dir + '/*.monitrc') }/) }
end

# case os[:family]
# when 'freebsd'
#  describe file('/etc/rc.conf.d/monit') do
#    it { should be_file }
#  end
# end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

describe file(config_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  it { should be_mode 755 }
end

describe file("#{config_dir}/sshd.monitrc") do
  it { should exist }
  it { should be_file }
  it { should be_mode 600 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  if os[:family] == "redhat"
    its(:content) { should match(/^\s+start program "#{Regexp.escape('/bin/systemctl')} start sshd"$/) }
  else
    its(:content) { should match(/#{ Regexp.escape('start program "' + ssh_rc_command[:start] + '"') }/) }
    its(:content) { should match(/#{ Regexp.escape('stop program "' + ssh_rc_command[:stop] + '"') }/) }
  end
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe file("#{script_dir}/isakmpd_start") do
  it { should exist }
  it { should be_file }
  it { should be_mode 755 }
  its(:content) { should match Regexp.escape("#!/bin/sh") }
  its(:content) { should match(/echo "isakmpd start"/) }
end
