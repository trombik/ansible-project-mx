require "English"

# `virtualbox` environment
class TestEnvironment
  def initialize; end

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

  def up
    vagrant "up --no-provision"
  end

  def clean
    vagrant "destroy -f"
  end

  def provision
    vagrant "provision"
  end

  def prepare
    vagrant "provision"
  end

  def user
    "vagrant"
  end
end
