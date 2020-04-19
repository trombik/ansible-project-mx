require "English"

# `virtualbox` environment
class Inventory
  def self.exec_and_abort_if_fail(cmd)
    status = system cmd
    warn "`#{cmd}` failed." unless $CHILD_STATUS.exitstatus.zero?
    abort unless $CHILD_STATUS.exitstatus.zero?
    status
  end

  def self.vagrant(args)
    Bundler.with_clean_env do
      exec_and_abort_if_fail "vagrant #{args}"
    end
  end

  def self.up
    vagrant "up --no-provision"
  end

  def self.clean
    vagrant "destroy -f"
  end

  def self.provision
    vagrant "provision"
  end

  def self.prepare
    vagrant "provision"
  end

  def self.user
    "vagrant"
  end
end
