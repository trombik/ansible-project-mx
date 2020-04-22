# frozen_string_literal: true

require "rake"

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
    sh "terraform apply #{plan_path}"

    # make sure the cache is up-to-date
    sh "#{inventory_path}/ec2.py --refresh-cache"

    # make sure all hosts are ready for ansible play
    retry_opts = {
      max_tries: 10, base_sleep_seconds: 10, max_sleep_seconds: 30
    }
    with_retries(retry_opts) do |_attempt_number|
      sh "ansible -i #{inventory_path} --ssh-common-args '-o \"UserKnownHostsFile /dev/null\" -o \"StrictHostKeyChecking no\"' --user 'ec2-user' -m ping all"
    end
  end

  def clean
    sh "terraform destroy -force #{plan_path}"
  end

  def provision
    sh "ansible-playbook -i #{inventory_path} --ssh-common-args '-o \"UserKnownHostsFile /dev/null\" -o \"StrictHostKeyChecking no\"' --user 'ec2-user' playbooks/site.yml"
  end

  def prepare
    # NOOP
  end

  def user
    "ec2-user"
  end
end
