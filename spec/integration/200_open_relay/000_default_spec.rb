require_relative "../spec_helper"
require "net/smtp"

all_hosts_in("mx").each do |server|
  describe server do
    let(:smtp) { Net::SMTP.new(current_server.address, 25) }
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
      let(:to) { "john@trombik.org" }
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
