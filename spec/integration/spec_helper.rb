require_relative "../spec_helper"
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
