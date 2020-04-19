# `staging` environment
#
# creates the environment in EC2, using terraform.
class Inventory
  def self.plan_path
    "terraform/plans/#{ansible_environment}"
  end

  def self.up
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

  def self.clean
    sh "terraform destroy -force #{plan_path}"
  end

  def self.provision
    sh "ansible-playbook -i #{inventory_path} --ssh-common-args '-o \"UserKnownHostsFile /dev/null\" -o \"StrictHostKeyChecking no\"' --user 'ec2-user' playbooks/site.yml"
  end

  def self.prepare
    # NOOP
  end

  def self.user
    "ec2-user"
  end
end
