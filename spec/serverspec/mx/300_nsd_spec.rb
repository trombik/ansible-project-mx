require_relative "../spec_helper"

inventory = AnsibleInventory.new("inventories/#{ENV['ANSIBLE_ENVIRONMENT']}/#{ENV['ANSIBLE_ENVIRONMENT']}.yml")

describe service "nsd" do
  it { should be_enabled }
  it { should be_running }
end

describe port 53 do
  it { should be_listening }
end

dig_command = case os[:family]
              when "freebsd"
                "drill"
              else
                "dig"
              end
nsd_user = case os[:family]
           when "openbsd"
             "_nsd"
           else
             "nsd"
           end

vip = inventory.host("mx1.trombik.org")["ansible_host"]

# XXX use YAML
domains = [
  {
    name: "trombik.org",
    ns: %w[a.ns.trombik.org b.ns.trombik.org],
    mx: [
      { name: "mx.trombik.org", address: vip, prio: 50 }
    ],
    a: [
      { name: "www", addresses: [vip] }
    ],
    cname: [
      { name: "cdn", addresses: ["cdn.example.org"] }
    ],
    txt: [
      { name: "", addresses: %w[foo bar] },
      { name: "txt", addresses: %w[buz] }
    ],
    vip: vip
  },
  {
    name: "mkrsgh.org",
    ns: %w[a.ns.mkrsgh.org b.ns.mkrsgh.org],
    mx: [],
    a: [
      { name: "rep", addresses: [vip] }
    ],
    cname: [],
    txt: [],
    vip: vip
  }
]

domains.each do |domain|
  describe file("/var/nsd/etc/#{domain[:name]}") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into nsd_user }
    it { should be_mode 640 }
    its(:content) { should match(/^#{domain[:name]}\.\s+\d+\s+IN SOA a.ns.#{domain[:name]}. hostmaster.#{domain[:name]}. \d+ \d+ \d+ \d+ \d+$/) }
    its(:content) { should match(/^;; Managed by ansible$/) }
    its(:content) { should match(/\$TTL 86400$/) }
    its(:content) { should match(/^#{domain[:name]}.\s+\d+\s+IN\s+NS a.ns$/) }
    its(:content) { should match(/^#{domain[:name]}.\s+\d+\s+IN\s+NS b.ns$/) }
    its(:content) { should match(/^a.ns\s+\d+\s+IN\s+A\s+#{domain[:vip]}$/) }
    its(:content) { should match(/^b.ns\s+\d+\s+IN\s+A\s+#{domain[:vip]}$/) }
    domain[:a].each do |a|
      a[:addresses].each do |addr|
        its(:content) { should match(/^#{a[:name]}\s+IN\s+A\s+#{addr}$/) }
      end
    end
  end
end

domains.each do |domain|
  describe command("#{dig_command} @127.0.0.1 ns #{domain[:name]}. +norec") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    its(:stdout) { should match(/^;; flags: qr aa; QUERY: 1, ANSWER: #{domain[:ns].length}, AUTHORITY: 0, ADDITIONAL: #{domain[:ns].length}$/) }
    domain[:ns].each do |ns|
      its(:stdout) { should match(/^#{ns}.\s+\d+\s+IN\s+A\s+\d+/) }
    end
  end

  describe command("#{dig_command} @127.0.0.1 mx #{domain[:name]}. +norec") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    unless domain[:mx].empty?
      its(:stdout) { should match(/^;; flags: qr aa; QUERY: 1, ANSWER: #{domain[:mx].length}, AUTHORITY: #{domain[:ns].length}, ADDITIONAL: #{domain[:mx].length + domain[:ns].length}$/) }
      domain[:mx].each do |mx|
        its(:stdout) { should match(/^#{domain[:name]}.\s+\d+\s+IN\s+MX\s+#{mx[:prio]}\s+#{mx[:name]}\./) }
      end
    end
  end

  domain[:cname].each do |cname|
    describe command("#{dig_command} @127.0.0.1 cname #{cname[:name]}.#{domain[:name]}. +norec") do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq "" }
      cname[:addresses].each do |addr|
        its(:stdout) { should match(/^#{Regexp.escape(cname[:name])}\.#{domain[:name]}\.\s+\d+\s+IN\s+CNAME\s+#{Regexp.escape(addr)}\.$/) }
      end
    end
  end

  domain[:txt].each do |txt|
    describe command("#{dig_command} @127.0.0.1 txt #{txt[:name].empty? ? '' : txt[:name] + '.'}#{domain[:name]}. +norec") do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq "" }
      txt[:addresses].each do |address|
        its(:stdout) { should match(/^#{Regexp.escape(txt[:name].empty? ? "" : txt[:name] + ".")}#{domain[:name]}\.\s+\d+\s+IN\s+TXT\s+"#{Regexp.escape(address)}"$/) }
      end
    end
  end
end

describe command("#{dig_command} @127.0.0.1 chaos txt version.bind") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should_not match(/version\.bind\..*".*"/) }
end
