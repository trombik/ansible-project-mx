# frozen_string_literal: true

require_relative "../spec_helper"
require "dnsruby"

domains = %w[trombik.org mkrsgh.org]
mx = %w[mx.trombik.org]
ns = %w[a.ns.trombik.org b.ns.trombik.org]

inventory.all_hosts_in("mx").each do |server|
  address = inventory.host(server)["ansible_host"]
  describe "server #{address}" do
    let(:resolver) { Dnsruby::DNS.new(nameserver: address) }

    it "has valid NS" do
      resolver.each_resource("trombik.org", "NS") do |rr|
        expect(ns).to include(rr.domainname.to_s)
      end
    end

    it "has valid MX" do
      resolver.each_resource("trombik.org", "MX") do |rr|
        expect(mx).to include(rr.exchange.to_s)
      end
    end

    it "returns valid address of www.trombik.org" do
      resolver.each_resource("www.trombik.org", "A") do |rr|
        expect(rr.address.to_s).to eq address
      end
    end

    domains.each do |domain|
      describe domain do
        it "has SPF TXT record" do
          records = []
          resolver.each_resource(domain, "TXT") do |rr|
            # XXX TXT RDATA includes `"` at the begining and the end
            records << rr.rdata_to_string.gsub(/^"/, "").gsub(/"$/, "")
          end
          expect(records).to include("v=spf1 mx -all")
        end
      end
    end
  end
end
