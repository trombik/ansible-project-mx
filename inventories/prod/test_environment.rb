# frozen_string_literal: true

require "rake"
require "shellwords"

# `staging` environment
#
# creates the environment in EC2, using terraform.
class TestEnvironment
  include FileUtils

  def initialize; end

  def plan_path
    "terraform/plans/#{ansible_environment}"
  end

  def up
    sh "terraform apply #{Shellwords.escape(plan_path)}"

    # make sure the cache is up-to-date
    sh "#{inventory_path + '/ec2.py'} --refresh-cache"

    # make sure all hosts are ready for ansible play
    retry_opts = {
      max_tries: 10, base_sleep_seconds: 10, max_sleep_seconds: 30
    }
    with_retries(retry_opts) do |_attempt_number|
      sh "ansible -i #{inventory_path} " \
         "--ssh-common-args '-o \"UserKnownHostsFile /dev/null\" -o \"StrictHostKeyChecking no\"'" \
         "--user #{Shellwords.escape(user)} -m ping all"
    end
  end

  def clean
    sh "terraform destroy #{Shellwords.escape(plan_path)}"
  end

  def ask_become_pass_flags
    if ENV["ANSIBLE_USER"] && ENV["ANSIBLE_USER"] == "ec2-user"
      ""
    else
      "--ask-become-pass"
    end
  end

  def provision
    sh "ansible-playbook -i #{Shellwords.escape(inventory_path)} " \
      "#{Shellwords.escape(ask_become_pass_flags)} " \
      "--ssh-common-args '-o \"UserKnownHostsFile /dev/null\" -o \"StrictHostKeyChecking no\"' " \
      "--user #{Shellwords.escape(user)} playbooks/site.yml"
  end

  def prepare
    # NOOP
  end

  def user
    ENV["PROJECT_USER"] || ENV["USER"]
  end
end
