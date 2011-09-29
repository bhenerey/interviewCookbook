#
# Cookbook Name:: interview
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "libshadow-ruby1.8" do
  action :install
end

user "interview" do
  username "interview"
  comment "Interview User"
  uid "1010"
  gid "opseng"
  home "/home/interview"
  shell "/bin/bash"
  password "$6$VqJMvyyRUrIBC$R8d5EAz1mD7OsK0Hl5dAKbFjHyPVcbNg8Cg6OJoywzdU9s3a1XBXSHDEtoLsjaUAfUNOOi6ZrI/NTa7DnGgvA1"
end

directory "/home/interview" do
  owner "interview"
  group "opseng"
  mode "0700"
end

bash "enable_password_authentication" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  sed -E 's/^.*(PasswordAuthentication).*$/PasswordAuthentication yes/g' -i /etc/ssh/sshd_config
  EOH
end

service "restart_ssh" do
  service_name "ssh"
  action :restart
end

# Create Apache configuration files
directory "/etc/apache2/sites-available" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

cookbook_file "/etc/apache2/sites-available/default" do
    source "default"
    mode "0644"
end

cookbook_file "/etc/apache2/ports.conf" do
    source "ports.conf"
    mode "0644"
end

cookbook_file "/home/interview/readme.txt" do
    source "readme.txt"
    mode "0644"
end

cookbook_file "/root/webloop.sh" do
    source "webloop.sh"
    mode "0755"
end

# Setup screen

package "screen" do
  action :install
end

# Create Screen configuration file
cookbook_file "/home/interview/.screenrc" do
    source "screenrc"
    owner "interview"
    group "opseng"
    mode "0644"
end

# Create .bashrc file
cookbook_file "/home/interview/.bashrc" do
    source "bashrc"
    owner "interview"
    group "opseng"
    mode "0644"
end

# Create .profile file
cookbook_file "/home/interview/.profile" do
    source "profile"
    owner "interview"
    group "opseng"
    mode "0644"
end

bash "ip_tables" do
  user "root"
  cwd "/tmp"
  not_if "test -f /var/run/iptables"
  code <<-EOH
  iptables -A INPUT -p tcp --source 127.0.0.1 --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp --dport 80 -j DROP
  touch /var/run/iptables
  EOH
end

bash "run_web_loop" do
  user "root"
  cwd "/tmp"
  not_if "pgrep -f SimpleHTTPServer"
  code <<-EOH
  /root/webloop.sh &
  touch /var/run/webloop
  EOH
end

