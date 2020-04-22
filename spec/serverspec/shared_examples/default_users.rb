# frozen_string_literal: true

shared_examples "a host with default users" do
  home = case os[:family]
         when "freebsd"
           "/use/home"
         else
           "/home"
         end
  yaml = case test_environment
         when "virtualbox"
           YAML.load_file("playbooks/group_vars/virtualbox-credentials.yml")
         else
           YAML.safe_load(Ansible::Vault.decrypt(file: "playbooks/group_vars/#{test_environment}-credentials.yml"))
         end
  users = yaml["project_users"]
  users.each do |u|
    describe user u["name"] do
      it { should exist }
      u["groups"].each do |g|
        it { should belong_to_group g }
      end
      it { should belong_to_primary_group u["group"] }
      it { should have_home_directory "#{home}/#{u['name']}" }
      u["ssh_public_keys"].each do |k|
        it { should have_authorized_key k }
      end
    end

    describe file "#{home}/#{u['name']}/.ssh" do
      it { should exist }
      it { should be_directory }
    end

    next unless u.key?("ssh_rc")

    describe file "#{home}/#{u['name']}/.ssh/rc" do
      it { should exist }
      it { should be_file }
      it { should be_owned_by u["name"] }
    end
  end

  if os[:platform] == "openbsd"
    u.select { |u| u["group"] == "wheel" }.each do |wheel_user|
      describe command "awk -F ':' '$1 == \"wheel\" { print $4 }' /etc/group" do
        its(:exit_status) { should eq 0 }
        its(:stderr) { should eq "" }
        it "should include #{wheel_user['name']}" do
          expect(subject.stdout.chomp.split(",")).to include(wheel_user["name"])
        end
      end
    end
  end
end
