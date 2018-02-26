require_relative "../spec_helper"
require "net/imap"

all_hosts_in("mx").each do |s|
  context "when unauthenticated" do
    describe s do
      let(:imap) do
        Net::IMAP.new(s.server.address, ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
      end

      it "authenticates valid user" do
        expect { imap.authenticate("PLAIN", "john@trombik.org", "PassWord") }.not_to raise_exception
      end
    end
  end

  context "when authenticated" do
    describe s do
      id = Time.new.to_i
      subject = "Test-#{id}"
      msg_id = nil
      imap = Net::IMAP.new(s.server.address, ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE })

      before(:all) do
        s.server.ssh_exec("echo test | mail -s #{subject} john@trombik.org")
        imap.authenticate("PLAIN", "john@trombik.org", "PassWord")
      end

      after(:all) do
        imap.select("INBOX")
        msg_id = imap.search(["SUBJECT", subject])
        imap.uid_store(msg_id, "+FLAGS", [:Deleted])
        imap.expunge
        imap.disconnect
      end

      it "has created INBOX" do
        expect { imap.select("INBOX") }.not_to raise_exception
      end

      it "has received the test message" do
        imap.select("INBOX")
        expect(msg_id = imap.search(["SUBJECT", subject]).length).to eq 1
      end
    end
  end
end
