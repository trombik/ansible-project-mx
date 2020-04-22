require_relative "../spec_helper"
require "dnsruby"

mx = %w[mx.trombik.org]
ns = %w[a.ns.trombik.org b.ns.trombik.org]

all_hosts_in("mx").each do |server|
  describe "server #{server.address}" do
    let(:resolver) { Dnsruby::DNS.new(nameserver: server.address) }

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
        expect(rr.address.to_s).to eq server.address
      end
    end
  end
end