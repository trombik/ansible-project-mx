require_relative "../spec_helper"
require "net/imap"
require "net/smtp"

inventory = AnsibleInventory.new("inventories/#{ENV['ANSIBLE_ENVIRONMENT']}/#{ENV['ANSIBLE_ENVIRONMENT']}.yml")

inventory.all_hosts_in("mx").each do |server|
  context "when unauthenticated" do
    let(:address) { inventory.host(server)["ansible_host"] }
    describe server do
      let(:imap) do
        Net::IMAP.new(address, ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
      end

      it "authenticates valid user" do
        expect { imap.authenticate("PLAIN", "john@trombik.org", "PassWord") }.not_to raise_exception
      end
    end
  end

  context "when authenticated" do
    describe server do
      address = inventory.host(server)["ansible_host"]
      user = "john@trombik.org"
      password = "PassWord"
      smtp = Net::SMTP.new(address, 587)
      ctx = OpenSSL::SSL::SSLContext.new
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE if test_environment != "prod"
      smtp.enable_tls(ctx)

      msg_id = nil
      imap = nil
      subject = "Test-#{Time.new.to_i}"
      msg = "Subject: #{subject}\n\ntest"

      before(:all) do
        smtp.start(address, user, password, :plain)
        smtp.send_message(msg, user, user)
        smtp.finish
        imap = Net::IMAP.new(address, ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
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
