require_relative "../spec_helper"

describe service "nsd" do
  it { should be_enabled }
  it { should be_running }
end

describe port 53 do
  it { should be_listening }
end
