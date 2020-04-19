require_relative "../spec_helper"
require "net/smtp"

all_hosts_in("mx").each do |server|
  describe "smtpd on #{server}" do
    let(:smtp) do
      o = Net::SMTP.new(server.address, 587)
      ctx = OpenSSL::SSL::SSLContext.new
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE if test_environment != "prod"
      o.enable_tls(ctx)
      o
    end
    let(:user) { "john@trombik.org" }
    let(:password) { "PassWord" }
    let(:invalid_user) { "dave.null@trombik.org" }
    let(:invalid_password) { "foobarbuz" }

    after(:each) { smtp.finish if smtp.started? }

    context "when SMTP client is authenticated" do
      before(:each) { smtp.start("localhost", user, password, :plain) }

      it "accepts message to third-party domain" do
        expect { smtp.mailfrom(user) }.not_to raise_exception
        expect { smtp.rcptto("foo@example.org") }.not_to raise_exception
      end

      it "accepts message to our domain" do
        expect { smtp.mailfrom(user) }.not_to raise_exception
        expect { smtp.rcptto("postmaster@trombik.org") }.not_to raise_exception
      end

      it "delivers a message to test user" do
        expect do
          smtp.send_message "Subject: Test message\n\nHello World",
                            user,
                            user
        end.not_to raise_exception
      end
    end

    context "when SMTP client does not send AUTH first" do
      before(:each) { smtp.start("localhost") }

      it "raises Net::SMTPAuthenticationError" do
        expect { smtp.mailfrom(user) }.to raise_exception(Net::SMTPAuthenticationError)
      end
    end

    context "when SMTP client fails to send correct credential" do
      it "raises Net::SMTPAuthenticationError" do
        expect do
          smtp.start("localhost", invalid_user, invalid_password, :plain).to
          raise_exception(Net::SMTPAuthenticationError)
        end
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
