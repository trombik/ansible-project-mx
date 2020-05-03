require "spec_helper"
require "serverspec"

service = "httpd"
config  = "/etc/httpd.conf"
ports   = [80]
log_dir = "/var/www/logs"
default_user = "root"
default_group = "wheel"

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  it { should be_mode 644 }
  its(:content) { should match(/^# Managed by ansible/) }
  its(:content) { should match Regexp.escape("ext_addr=\"*\"") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by default_user }
  it { should be_grouped_into "daemon" }
end

describe file("#{log_dir}/secure") do
  it { should exist }
  it { should be_directory }
  it { should be_mode 775 }
  it { should be_owned_by default_user }
  it { should be_grouped_into "daemon" }
end

describe file("/etc/rc.conf.local") do
  it { should exist }
  it { should be_file }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  it { should be_mode 644 }
  its(:content) { should match(/httpd_flags=#{Regexp.escape("-f /etc/httpd.conf")}$/) }
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe command("ftp -M -d -o /dev/null http://localhost/bgplg/index.html") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/#{Regexp.escape("HTTP/1.0 200 OK")}/) }
  its(:stderr) { should eq "" }
end
