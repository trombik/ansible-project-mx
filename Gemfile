source "https://rubygems.org"

gem "ansible-inventory-yaml", git: "https://github.com/trombik/ansible-inventory-yaml.git", branch: "master"
gem "ansible-vault", git: "https://github.com/trombik/ansible-vault", branch: "master"
gem "highline"
gem "rake"
gem "vagrant-serverspec", git: "https://github.com/trombik/vagrant-serverspec.git", branch: "master"
gem "vagrant-ssh-config", git: "https://github.com/trombik/vagrant-ssh-config.git", branch: "master"

group :development, :test do
  # gem "capybara"
  gem "retries", "~> 0.0.5"
  gem "rspec", "~> 3.4.0"
  gem "rspec-retry", "~> 0.5.5"
  gem "rubocop", "~> 0.51.0"
  # gem "selenium-webdriver"
  gem "serverspec"
  gem "dnsruby"
  gem "irb"

  # TODO: remove these legacy gems
  gem "infrataster", ">= 0.3.2", git: "https://github.com/trombik/infrataster.git", branch: "reallyenglish"
  gem "infrataster-plugin-firewall", ">= 0.1.4", git: "https://github.com/trombik/infrataster-plugin-firewall.git", branch: "reallyenglish"
end
