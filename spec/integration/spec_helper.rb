require_relative "../spec_helper"
require "infrataster/rspec"
require "infrataster-plugin-firewall"
require "ansible/vault"

# XXX `vagrant` command must be called within `with_clean_env`, not only
# `vagrant` command in this file, but also all other invocations in other
# places, such as libraries that depend on `vagrant` command, and spec files.

ENV["VAGRANT_CWD"] = Pathname.new(File.dirname(__FILE__)).parent.parent.to_s

# XXX inject vagrant `bin` path to ENV["PATH"]
# https://github.com/reallyenglish/packer-templates/pull/48
vagrant_path = ""
Bundler.with_clean_env do
  gem_which_vagrant = `gem which vagrant 2>/dev/null`.chomp
  if gem_which_vagrant != ""
    vagrant_path = Pathname
                   .new(gem_which_vagrant)
                   .parent
                   .parent + "bin"
  end
end
ENV["PATH"] = "#{vagrant_path}:#{ENV['PATH']}"

# Returns all server objects
#
# @return [Array<Infrataster::Resources::ServerResource>] array of server
#         objects
def all_servers
  Infrataster::Server.defined_servers.map { |i| server(i.name) }
end

# Returns server objects in a group
#
# @param [String] group name
# @return [Array<Infrataster::Resources::ServerResource>] array of server
#         objects
def all_hosts_in(group)
  inventory.all_hosts_in(group).map { |i| server(i.to_sym) }
end

# Returns raw, machine-readable content of `vagrant status`
#
# @return [String] output of `vagrant status`
def vagrant_status
  out = ""
  Bundler.with_clean_env do
    out = `vagrant status --machine-readable`
    unless $CHILD_STATUS.exitstatus.zero?
      raise StandardError, "Failed to run vagrant status"
    end
  end
  out
end

# Returns ansible-inventory outputs that includes all hosts
#
# @return [String] output of `ansible-inventory` as YAML
def ansible_inventory_list
  cmd = "ansible-inventory -i inventories/#{test_environment} --yaml --list"
  out = `#{cmd}`
  raise "failed to run command `#{cmd}`" unless $CHILD_STATUS.exitstatus.zero?
  out
end

# List of vagrant machine names
#
# @return [Array<String>] array of vagrant machine names
def vagrant_machines
  case test_environment
  when "virtualbox"
    vagrant_status.split("\n").select { |l| l.split(",")[2] == "metadata" }
                  .map { |l| l.split(",")[1] }
  when "staging"
    hosts = YAML.safe_load(ansible_inventory_list)["all"]["children"]["ec2"]["hosts"]
    hosts.keys.map { |k| hosts[k]["ec2_tag_Name"] }
  else
    raise "unknown test_environment `#{test_environment}`"
  end
end

vagrant_machines.each do |server|
  unless inventory.host(server).key?("ansible_host")
    raise "server `#{server}` does not have `ansible_host` in the inventory"
  end
  Bundler.with_clean_env do
    Infrataster::Server.define(
      server.to_sym,
      inventory.host(server)["ansible_host"],
      vagrant: case test_environment
               when "virtualbox"
                 true
               else
                 false
               end,
      ssh: case test_environment
           when "staging"
             { host_name: inventory.host(server)["ansible_host"], user: "ec2-user" }
           end
    )
  end
end
