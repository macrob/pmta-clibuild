#!/bin/bash
./pmta-cli config-generate -s "/root/pmta-clibuild/pmta"

cp -f ~/pmta-clibuild/build/config /etc/pmta/
cp -f -r ~/pmta-clibuild/build/conf.d /etc/pmta/