#!/bin/bash
yum install fish htop rsync perl git unzip net-tools ufw vim -y

mkdir ~/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDb9Zf1NQaWgaVXXls1WI5MRsubYi2WB2VjFzlAfEO38a+NFEbwqkOGwayUtsncIamn7jB5Hni8D72DuOFqWPYcdbiEapryvtNq0HesjLkqkby/8k+2NRiEf29Z/ujFnMtRS+cXDdpcSkcMcWLcHWMUkH1AzRYYxnSPLUMq4j4pHQ3jpJPNTSKqAsFRamEyMmaY9U+Ft5qfKNO7Fe7fJyZvPmdJ/2SlV9Zjd9C9rS80IwNeZ9B8m5R4roMnx3h9BOHYtX47zco0gu0mlRVMSYzLD5uDSfz/F5Tb7qJdqvwjCAZZdcLlwd5lg/6QrE+kM9O/Jr0UDbwldc9paA2OGNA7 rsa 2048' >> ~/.ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZiSVLsSuCsQwDfu/rs7tKMteUbKyh+y/SKaCzE3r5YB+n/SZjMw0+LVXSfqCQC4VJVKsthf4LxsCoM1ZK47W/M6jAOOXlMAW6c4FWKk8IYGliyxlNJxH2kiOnICMDmmpsYEuOOLt0M/GcJeS1wy8sfHzEpnl0RKylWiwXqItHVfc6haWFCTfdpQgeAoem14qI8+iKt58aMWnm5CxKQK99lVFaQogO7ClbrAstMB4595eqrFKKQ0fKVWqSuMaLjqE8ZabySFVnM/sB2N3Kz9iVl06cJjYL6dIHdu1YjhPnaixG+aT2XPbGshIh74Aw4XekIeV92KNu3h8Pvxruz/u3kY1zveigItTsvA1IW98x1b6oCo28V/UUC7uGYe2WM+Z16qYRaDUBZ8D6rKPYBsQmtXy8si7if6bBjd6RYKhgLBlkAc/g2YIvqabBAvJtBK87qiumtXe8A8UJGdb4suXkhj5YloXV1pQgDlx/gb+GqJQx1wF35Sirh5gmFmHZfVk= mac@Kseniyas-MacBook-Pro-2.local' >> ~/.ssh/authorized_keys

sed -i "s/#Port 22/Port 3784/" /etc/ssh/sshd_config
sed -i -r 's/^PasswordAuthentication\ yes/PasswordAuthentication\ no/g' /etc/ssh/sshd_config

semanage port -a -t ssh_port_t -p tcp 3784

sudo systemctl status firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld
systemctl unmask --now firewalld
service sshd restart;


sudo ufw status

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 3784 # SSH PORT
sudo ufw allow 2082

sudo ufw enable;
systemctl enable ufw;

cat >/etc/security/limits.d/nofile.conf <<EOL
* soft nofile 100000
* hard nofile 100000
root hard nofile 100000
root soft nofile 100000
EOL


echo "fs.file-max = 100000" >> /etc/sysctl.conf

sysctl -p
systemctl daemon-reload

sed -i -e "s/^SELINUX=.*/SELINUX=permissive/" /etc/selinux/config
setenforce 0
ulimit -H -u 80000
ulimit -H -n 80000

chmod 755 ~/pmta-clibuild/powerMTA/PowerMTA-5.0b1.rpm
rpm -ivh ~/pmta-clibuild/powerMTA/PowerMTA-5.0b1.rpm

unzip ~/pmta-clibuild/powerMTA/patch.zip -d ~/
chmod +x ~/patch/usr/sbin/pmtad
chmod +x ~/patch/usr/sbin/pmtahttpd

mv ~/patch/usr/sbin/pmtad /usr/sbin/
mv ~/patch/usr/sbin/pmtahttpd /usr/sbin/
cp ~/patch/etc/pmta/license /etc/pmta/

