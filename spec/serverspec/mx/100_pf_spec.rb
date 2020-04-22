# frozen_string_literal: true

require_relative "../spec_helper"

describe command "pfctl -sr" do
  its(:exit_status) { should match eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/block drop log all/) }
end
