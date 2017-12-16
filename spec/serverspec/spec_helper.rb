require "serverspec"
require "net/ssh/proxy/command"
require_relative "../spec_helper"
Dir[File.dirname(__FILE__) + "/types/*.rb"].each { |f| require f }
Dir[File.dirname(__FILE__) + "/shared_examples/*.rb"].each { |f| require f }

host = ENV["TARGET_HOST"]

ssh_options = Vagrant::SSH::Config.for(host)
proxy = if ssh_options.key?("ProxyCommand".downcase)
          Net::SSH::Proxy::Command.new(ssh_options["ProxyCommand".downcase])
        else
          false
        end

options = {
  host_name: ssh_options["HostName".downcase],
  port: ssh_options["Port".downcase],
  user: ssh_options["User".downcase],
  keys: ssh_options["IdentityFile".downcase],
  keys_only: ssh_options["IdentitiesOnly".downcase],
  paranoid: ssh_options["StrictHostKeyChecking".downcase]
}
options[:proxy] = proxy if proxy

set :backend, :ssh
set :sudo_password, ENV["SUDO_PASSWORD"]

set :host, host
set :ssh_options, options
set :request_pty, true
set :env, LANG: "C", LC_MESSAGES: "C"
