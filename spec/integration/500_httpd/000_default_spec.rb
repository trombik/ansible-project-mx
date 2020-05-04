# frozen_string_literal: true

require_relative "../spec_helper"
require "net/http"

alias_domains = %w[www.trombik.org mail.trombik.org mx.trombik.org]
domain = "trombik.org"

yaml = YAML.load_file(Pathname.new("playbooks") + "group_vars" + "#{test_environment}.yml")
project_acme_client_bootstrapped = yaml["project_acme_client_bootstrapped"]

case project_acme_client_bootstrapped
when false
  inventory.all_hosts_in("mx").each do |server|
    describe "httpd on #{server}" do
      let(:address) { inventory.host(server)["ansible_host"] }

      alias_domains.each do |d|
        describe "HTTP request to #{d}" do
          it "redirects to #{domain}" do
            res = Net::HTTP.start(address, 80) do |http|
              request = Net::HTTP::Get.new "/.well-known/acme-challenge/foo"
              request["Host"] = d
              http.request(request)
            end
            expect(res.code).to eq "301"
          end
        end
      end
    end
  end
when true
  inventory.all_hosts_in("mx").each do |server|
    describe "httpd on #{server}" do
      let(:address) { inventory.host(server)["ansible_host"] }

      alias_domains.each do |d|
        describe "HTTPS request to #{d}" do
          it "redirects to #{domain}" do
            res = Net::HTTP.start(address, 443, use_ssl: true) do |http|
              request = Net::HTTP::Get.new "/.well-known/acme-challenge/foo"
              request["Host"] = d
              http.request(request)
            end
            expect(res.code).to eq "200"
          end
        end
      end
    end
  end
end
