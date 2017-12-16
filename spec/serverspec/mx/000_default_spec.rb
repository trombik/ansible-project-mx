require_relative "../spec_helper"

fqdn = "mx1.trombik.org"

describe fqdn do
  it_behaves_like "a host with all basic tools installed"
end

describe service "smtpd" do
  it { should be_enabled }
  it { should be_running }
end

cmd = "route -n get default | awk '/if address:/ { print $3 }'"
describe command cmd do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^\d+\.\d+\.\d+\.\d+$/) }
end
egress_address = Specinfra.backend.run_command(cmd).stdout.chomp

extra_opt = test_environment == "prod" ? "-verify_return_error" : ""
describe command "(sleep 3; echo helo localhost) | openssl s_client -connect #{egress_address}:587 #{extra_opt}" do
  # XXX SMTP is in a world of `CRLF`. remove `CR` so that regex `$` matches
  # the end of line
  let(:reply) { subject.stdout.gsub(/\015/, "") }

  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { match(/^CONNECTED.+$/) }
  it "replies with SMTP banner" do
    expect(reply).to match(/^220 #{Regexp.escape(fqdn)} ESMTP OpenSMTPD$/)
    expect(reply).to match(/^250 #{Regexp.escape(fqdn)} Hello localhost \[\d+\.\d+\.\d+\.\d+\], pleased to meet you$/)
  end
end
