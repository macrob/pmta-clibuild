# pmta-clibuild

example of use:
./pmta-cli config-generate -s "./pmta"

sudo ln -s /root/pmta-clibuild/callcenter.service /etc/systemd/system/
sudo systemctl enable --now callcenter

sudo service callcenter start