#!/bin/bash

sudo ln -s /root/pmta-clibuild/callcenter.service /etc/systemd/system/
sudo systemctl enable --now callcenter

sudo service callcenter start