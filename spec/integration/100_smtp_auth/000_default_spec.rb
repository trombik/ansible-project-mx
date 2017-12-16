require_relative "../spec_helper"
require "net/smtp"

all_hosts_in("mx").each do |server|
  describe server do
    let(:smtp) do
      o = Net::SMTP.new(current_server.address, 587)
      ctx = OpenSSL::SSL::SSLContext.new
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE if test_environment != "prod"
      o.enable_tls(ctx)
      o
    end
    let(:user) { "john@trombik.org" }
    let(:password) { "PassWord" }

    after(:each) { smtp.finish if smtp.started? }

    context "when SMTP client is authenticated" do
      before(:each) { smtp.start("localhost", user, password, :plain) }
      it "accepts message to third-party domain" do
        skip "the test user does not exist in prod" if test_environment == "prod"
        expect { smtp.mailfrom(user) }.not_to raise_exception
        expect { smtp.rcptto("foo@example.org") }.not_to raise_exception
      end

      it "accepts message to our domain" do
        skip "the test user does not exist in prod" if test_environment == "prod"
        expect { smtp.mailfrom(user) }.not_to raise_exception
        expect { smtp.rcptto("postmaster@trombik.org") }.not_to raise_exception
      end
    end

    context "when SMTP client is not authenticated" do
      before(:each) { smtp.start("localhost") }

      it "rejects message without AUTH to third-party domain" do
        expect { smtp.mailfrom(user) }.to raise_exception(Net::SMTPAuthenticationError)
      end
    end

    context "when test environment is prod" do
      before(:each) { smtp.start("localhost", user, password, :plain) }

      it "rejects message from the test user, which should not exist in prod" do
        skip "the example is only for prod environment" if test_environment != "prod"
        expect { smtp.mailfrom(user) }.to raise_exception(Net::SMTPAuthenticationError)
      end
    end
  end
end
