# frozen_string_literal: true

require_relative "../spec_helper"
require "net/smtp"

RSpec.configure do |config|
  # XXX AWS imposes "limitations" on both ingress and egress SMTP connections.
  # https://console.aws.amazon.com/support/contacts?#/rdns-limits
  #
  # skip some tests that require SMTP in staging. you may keep an EIP without
  # SMTP limitations, but it costs extra fee per hour.
  config.filter_run_excluding type: "require_smtp_unblocking" if test_environment == "staging"
end

tos = credentials_yaml["project_test_users"]
inventory.all_hosts_in("mx").each do |server|
  describe "smtpd on #{server}", type: :require_smtp_unblocking do
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

    context "when to is one of test users" do
      let(:from) { "foo@example.org" }

      tos.each do |to|
        it "accepts message to #{to['name']}" do
          expect { smtp.mailfrom(from) }.not_to raise_exception
          expect { smtp.rcptto(to["name"]) }.not_to raise_exception
        end
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

    context "when client issues STRATTLS" do
      let(:starttls) do
        o = Net::SMTP.new(inventory.host(server)["ansible_host"], 25)
        # o.esmtp = true
        o.open_timeout = 30
        o.read_timeout = 30
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
        o.enable_starttls(ctx)
        o
      end
      let(:to) { "bar@example.net" }
      before(:each) { starttls.start("localhost") }
      after(:each) { starttls.finish if smtp.started? }

      context "and from is one of our domain," do
        let(:from) { "foo@trombik.org" }

        it "rejects message" do
          expect { starttls.mailfrom(from) }.not_to raise_exception
          expect { starttls.rcptto(to) }.to raise_exception(Net::SMTPFatalError)
        end
      end
    end
  end
end
