# frozen_string_literal: true

require_relative "../spec_helper"
require "net/smtp"

inventory.all_hosts_in("mx").each do |server|
  describe "smtpd on #{server}" do
    let(:smtp) do
      o = Net::SMTP.new(inventory.host(server)["ansible_host"], 25)
      o.open_timeout = 30
      o.read_timeout = 30
      o
    end
    let(:to) { "bar@example.net" }
    before(:each) { smtp.start("localhost.example.org") }
    after(:each) { smtp.finish if smtp.started? }

    context "when from is one of our domain" do
      let(:from) { "foo@trombik.org" }

      it "rejects message" do
        expect { smtp.mailfrom(from) }.not_to raise_exception
        expect { smtp.rcptto(to) }.to raise_exception(Net::SMTPFatalError)
      end
    end

    context "when from is third-party" do
      let(:from) { "foo@exmaple.org" }

      it "rejects message" do
        expect { smtp.mailfrom(from) }.not_to raise_exception
        expect { smtp.rcptto(to) }.to raise_exception(Net::SMTPFatalError)
      end
    end

    context "when to is a valid address of our domain" do
      let(:to) { credentials_yaml["project_test_user"]["name"] }
      let(:from) { "foo@example.org" }

      it "accepts message" do
        expect { smtp.mailfrom(from) }.not_to raise_exception
        expect { smtp.rcptto(to) }.not_to raise_exception
      end
    end

    context "when to is one of must-have addresses of our domain" do
      let(:from) { "foo@example.org" }

      ["abuse@trombik.org", "postmaster@trombik.org"].each do |to|
        it "accepts message to #{to}" do
          expect { smtp.mailfrom(from) }.not_to raise_exception
          expect { smtp.rcptto(to) }.not_to raise_exception
        end
      end
    end
  end
end
