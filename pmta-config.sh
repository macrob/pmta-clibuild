#!/bin/bash

###### CONFGIG CONST
dkimDir=/etc/dkim;
dkimKeyPth="${dkimDir}/dkim5.${domain}.key";
dkimPubPth="${dkimDir}/dkim5.${domain}.pub";

domain=`jq -r .domain config.json`;
echo "domain-key dkim5,$domain,${dkimKeyPth}" >> /etc/pmta/dkimlist.txt

./pmta-cli config-generate -s "/root/pmta-clibuild/pmta"

cp -f ~/pmta-clibuild/build/config /etc/pmta/
cp -f -r ~/pmta-clibuild/build/conf.d /etc/pmta/