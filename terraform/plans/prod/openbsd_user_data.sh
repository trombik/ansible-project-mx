#!/bin/sh
pkg_add python%2.7 curl sudo--
echo "#includedir /etc/sudoers.d" >> /etc/sudoers
mkdir -p /etc/sudoers.d
touch /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant
cat <<EOF > /etc/sudoers.d/ec2-user
Defaults:ec2-user !requiretty
ec2-user ALL=(ALL) NOPASSWD: ALL
root ALL=(ALL) NOPASSWD: ALL
EOF
cat <<EOF > /etc/boot.conf
set timeout 1
EOF
