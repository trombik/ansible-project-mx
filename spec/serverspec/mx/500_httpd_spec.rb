# frozen_string_literal: true

require_relative "../spec_helper"

ports = [80]

describe service "httpd" do
  it { should be_running }
end

ports.each do |p|
  describe port p do
    it { should be_listening }
  end
end
