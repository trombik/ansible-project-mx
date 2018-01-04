# Generated by `infrataster init`

require "English"
require "rake"
require "rspec/core/rake_task"
require "yaml"
require "net/ssh"
require "tempfile"
require "pathname"
require "highline/import"
require "vagrant/serverspec"
require "vagrant/ssh/config"
require "retries"
$LOAD_PATH.unshift(Pathname.new(File.dirname(__FILE__)) + "ruby" + "lib")
require "ansible_inventory"

def exec_and_abort_if_fail(cmd)
  status = system cmd
  warn "`#{cmd}` failed." unless $CHILD_STATUS.exitstatus.zero?
  abort unless $CHILD_STATUS.exitstatus.zero?
  status
end

def vagrant(args)
  Bundler.with_clean_env do
    exec_and_abort_if_fail "vagrant #{args}"
  end
end

def ansible_environment
  known_environment = %w[virtualbox staging prod]
  env = ENV["ANSIBLE_ENVIRONMENT"] ? ENV["ANSIBLE_ENVIRONMENT"] : "virtualbox"
  raise "unknown environment `#{env}`" unless known_environment.include?(env)
  env
end

def inventory_path
  "inventories/#{ansible_environment}"
end

def sudo_password
  ask("Enter sudo password: ") { |q| q.echo = false }
end

def sudo_password_required?(user)
  user != "root" && user != "vagrant" && user != "ec2-user"
end

def configure_sudo_password_for(run_as_user)
  ENV["SUDO_PASSWORD"] = sudo_password if
    sudo_password_required?(run_as_user) &&
    !ENV.key?("SUDO_PASSWORD")
end

def plan_path
  "terraform/plans/#{ansible_environment}"
end

desc "launch VMs"
task :up do
  case ansible_environment
  when "virtualbox"
    vagrant "up --no-provision"
  when "staging"
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
end

desc "destroy VMs"
task :clean do
  case ansible_environment
  when "virtualbox"
    vagrant "destroy -f"
  when "staging"
    sh "terraform destroy -force #{plan_path}"
  end
end

desc "vagrant provision"
task :provision do
  case ansible_environment
  when "virtualbox"
    vagrant "provision"
  when "staging"
    sh "ansible-playbook -i #{inventory_path} --ssh-common-args '-o \"UserKnownHostsFile /dev/null\" -o \"StrictHostKeyChecking no\"' --user 'ec2-user' playbooks/site.yml"
  end
end

desc "all all tests; serverspec, integration, and rubocop"
task test: [
  # probably, each target deserves its own Jenkins stage. but for now, I would
  # like to merge the branch first. or, the branch history will mess up.
  "test:rubocop:all",
  :up,
  :provision,
  "test:serverspec:all",
  "test:integration:all"
] do
end

# rubocop:disable Metrics/BlockLength:
namespace :test do
  desc "Prepare"
  task :prepare do
    case ansible_environment
    when "virtualbox"
      vagrant "up"
      vagrant "provision"
    end
  end

  desc "Provision"
  task :provision do
    case ansible_environment
    when "virtualbox"
      vagrant "provision"
    else
      warn "unknown environment `#{ansible_environment}`"
      exit 1
    end
  end

  desc "Restart VMs"
  task :restart do
    case ansible_environment
    when "virtualbox"
      vagrant "reload --provision"
    else
      warn "unknown environment `#{ansible_environment}`"
      exit 1
    end
  end

  desc "Clean"
  task :clean do
    case ansible_environment
    when "virtualbox"
      begin
        vagrant "destroy -f"
      ensure
        sh "rm -f *.vdi"
      end
    else
      warn "unknown environment `#{ansible_environment}`"
      exit 1
    end
  end

  namespace "serverspec" do
    inventory = AnsibleInventory.new(inventory_path)
    desc "Run serverspec on all hosts"
    task "all" do
      inventory.all_groups.each do |g|
        next unless Dir.exist?("spec/serverspec/#{g}")
        inventory.all_hosts_in(g).each do |h|
          # XXX pass SUDO_PASSWORD to serverspec if the user is required to
          # type password
          run_as_user = case ansible_environment
                        when "virtualbox"
                          Vagrant::SSH::Config.for(h)["User".downcase]
                        when "staging"
                          "ec2-user"
                        end
          configure_sudo_password_for(run_as_user)
          puts "running serverspec for #{g} on #{h} as user `#{run_as_user}`"
          Vagrant::Serverspec.new(inventory_path).run(group: g, hostname: h)
        end
      end
    end
    inventory.all_groups.each do |g|
      next unless Dir.exist?("spec/serverspec/#{g}")
      desc "Run serverspec for group `#{g}`"
      task g.to_sym do |_t|
        inventory.all_hosts_in(g).each do |h|
          # XXX !DRY
          run_as_user = case ansible_environment
                        when "virtualbox"
                          Vagrant::SSH::Config.for(h)["User".downcase]
                        when "staging"
                          "ec2-user"
                        end
          configure_sudo_password_for(run_as_user)
          puts "running serverspec for #{g} on #{h} as user `#{run_as_user}`"
          Vagrant::Serverspec.new(inventory_path).run(group: g, hostname: h)
        end
      end
    end
  end

  # XXX replace `serverspec` namespace with this when it is confirmed that the
  # tasks are acutually faster.
  namespace "para" do
    inventory = AnsibleInventory.new(inventory_path)
    inventory.all_groups.each do |g|
      next unless Dir.exist?("spec/serverspec/#{g}")
      inventory.all_hosts_in(g).each do |h|
        # XXX hide the tasks from the task list because it can be tested only
        # with remote hosts, not VMs on the same machine.
        #
        # desc "Run serverspec for group `#{g}` on #{h}"
        task "#{g}:#{h}" do |_t|
          Vagrant::Serverspec.new(inventory_path)
                             .run_with_fork(group: g, hostname: h)
        end
      end
    end

    inventory.all_groups.each do |g|
      next unless Dir.exist?("spec/serverspec/#{g}")
      # XXX hide the tasks from the task list because it can be tested only
      # with remote hosts, not VMs on the same machine.
      #
      # desc "Run serverspec for group `#{g}`"
      hosts = inventory.all_hosts_in(g)
      task g.to_sym => hosts.map { |h| "test:para:#{g}:#{h}" } do |_t|
        Process.waitall
      end
    end
  end

  namespace "integration" do
    # set the default user name in each environment
    run_as_user = case ansible_environment
                  when "virtualbox"
                    "vagrant"
                  when "staging"
                    "ec2-user"
                  when "prod"
                    ENV["USER"]
                  end

    # but if ANSIBLE_USER is defined by the user, override it
    run_as_user = ENV["ANSIBLE_USER"] if ENV["ANSIBLE_USER"]
    directories = Pathname.glob("spec/integration/[0-9][0-9][0-9]_*")
    directories.each do |d|
      desc "run integration spec #{d.basename}"
      task d.basename.to_s do
        vault_password_file = ENV["ANSIBLE_VAULT_PASSWORD_FILE"]
        test_env = ansible_environment
        Bundler.with_clean_env do
          ENV["ANSIBLE_ENVIRONMENT"] = test_env
          ENV["ANSIBLE_VAULT_PASSWORD_FILE"] = vault_password_file
          configure_sudo_password_for(run_as_user)
          sh "bundle exec rspec #{d}/*_spec.rb"
        end
      end
    end
    desc "Run integration test"
    task :all do
      # XXX run `bundler exec rspec` in a clean environment.
      # the difference from running `rspec` in bundler environment is that:
      # when invoking `rspec` within `with_clean_env`, the forked process can
      # escape, or shellout, from the bundler environment.
      #
      # `rspec` is a different process. when you invoke `rspec` without
      # `with_clean_env`, the bundler in `rspec` process keeps a copy of
      # original environemnt and replace current environment with the copy when
      # inside of `with_clean_env`. but because, in this case, the copied
      # environment inherits the bundler environment of `rake`, the environment
      # the process replaced is still bundler environment.
      vault_password_file = ENV["ANSIBLE_VAULT_PASSWORD_FILE"]
      test_env = ansible_environment
      Bundler.with_clean_env do
        ENV["ANSIBLE_ENVIRONMENT"] = test_env
        ENV["ANSIBLE_VAULT_PASSWORD_FILE"] = vault_password_file
        configure_sudo_password_for(run_as_user)
        sh "bundle exec rspec spec/integration/**/*_spec.rb"
      end
    end
  end

  namespace "rubocop" do
    desc "Run rubocop"
    task :all do
      sh "rubocop --display-cop-names --display-style-guide"
    end
  end
end
# rubocop:enable Metrics/BlockLength:
