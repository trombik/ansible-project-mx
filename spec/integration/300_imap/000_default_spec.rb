# frozen_string_literal: true

require_relative "../spec_helper"
require "net/imap"
require "net/smtp"

test_users = credentials_yaml["project_test_users"]

inventory.all_hosts_in("mx").each do |server|
  context "when unauthenticated" do
    let(:address) { inventory.host(server)["ansible_host"] }
    describe server do
      let(:imap) do
        Net::IMAP.new(address, ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
      end

      test_users.each do |test_user|
        it "authenticates valid user (#{test_user['name']})" do
          expect { imap.authenticate("PLAIN", test_user["name"], test_user["password"]) }.not_to raise_exception
        end
      end
    end
  end

  context "when authenticated" do
    describe server do
      test_users.each do |user|
        address = inventory.host(server)["ansible_host"]
        smtp = Net::SMTP.new(address, 587)
        smtp.open_timeout = 30
        smtp.read_timeout = 30
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
        smtp.enable_tls(ctx)

        msg_id = nil
        imap = nil
        subject = "Test-#{Time.new.to_i}"
        msg = "Subject: #{subject}\n\ntest"

        before(:all) do
          smtp.start(address, user["name"], user["password"], :plain)
          smtp.send_message(msg, user["name"], user["name"])
          smtp.finish
          imap = Net::IMAP.new(address, ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
          imap.authenticate("PLAIN", user["name"], user["password"])
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
end
