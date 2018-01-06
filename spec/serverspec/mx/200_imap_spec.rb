require_relative "../spec_helper"

describe service "dovecot" do
  it { should be_enabled }
  it { should be_running }
end

describe port 993 do
  it { should be_listening }
end

[143, 220].each do |p|
  describe port p do
    it { should_not be_listening }
  end
end

# XXX DRY
cmd = "route -n get default | awk '/if address:/ { print $3 }'"
egress_address = Specinfra.backend.run_command(cmd).stdout.chomp
extra_opt = test_environment == "prod" ? "-verify_return_error" : ""

describe command "(sleep 3; echo) | openssl s_client -connect #{egress_address}:993 #{extra_opt}" do
  let(:reply) { subject.stdout.gsub(/\015/, "") }

  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { match(/^CONNECTED.+$/) }
  it "replies with SMTP banner" do
    expect(reply).to match(/^\* OK \[CAPABILITY IMAP4rev1 LITERAL\+ SASL-IR LOGIN-REFERRALS ID ENABLE IDLE AUTH=PLAIN\] Dovecot ready\.$/)
  end
end