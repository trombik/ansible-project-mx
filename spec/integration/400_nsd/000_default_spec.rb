require_relative "../spec_helper"
require "dnsruby"

inventory = AnsibleInventory.new("inventories/#{ENV['ANSIBLE_ENVIRONMENT']}/#{ENV['ANSIBLE_ENVIRONMENT']}.yml")

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
  end
end
