#!/bin/bash

sudo yum -y update
sudo yum install -y epel-release
sudo yum install nginx certbot -y
sudo systemctl start nginx
sudo ufw allow 80
sudo ufw allow 443