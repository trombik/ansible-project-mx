require "English"
require "rspec/retry"
require "net/ssh"
require "pathname"
require "ansible/inventory/yaml"
require "vagrant/serverspec"
require "vagrant/ssh/config"

ENV["LANG"] = "C"

ENV["ANSIBLE_ENVIRONMENT"] = "virtualbox" unless ENV["ANSIBLE_ENVIRONMENT"]

# XXX OpenBSD needs TERM when installing packages
ENV["TERM"] = "xterm"

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "default"
  config.verbose_retry = true
  config.display_try_failure_messages = true
end

# Returns ANSIBLE_ENVIRONMENT
#
# @return [String] ANSIBLE_ENVIRONMENT if defined in ENV. defaults to "staging"
def test_environment
  ENV.key?("ANSIBLE_ENVIRONMENT") ? ENV["ANSIBLE_ENVIRONMENT"] : "virtualbox"
end

# Returns inventory object
#
# @return [Ansible::Inventory::YAML]
def inventory
  Ansible::Inventory::YAML.new(inventory_file)
end

# Returns path to inventory file
#
# @return [String]
def inventory_file
  Pathname.new(__FILE__)
          .parent
          .parent + "inventories" + test_environment + "#{test_environment}.yml"
end
