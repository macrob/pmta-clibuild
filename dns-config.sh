#!/bin/bash
domain=`jq -r .domain config.json`;
primaryIp=`jq -r .ip[0] config.json`;
ips=`jq -r .ip[] config.json`;

tmpFile=/tmp/vm;
pwd=`pwd`;

###### CONFGIG CONST
#uncomment next 1 lines;
dkimDir=/etc/dkim;
#dkimDir=./tmp/dkim/;
#uncomment next 1 lines;
zones=/etc/named/zones;
#zones=./tmp/zones;


rm -f $tmpFile;


zoneFile="${zones}/${domain}.zone"

cat > $tmpFile <<EOL
zone "${domain}" IN {
  type master;
  file "${zoneFile}";
  allow-update { none; };
};

EOL

#uncomment next 2 lines;
cat /tmp/vm >> /etc/named.conf
rm -f $tmpFile;

sh ./dns-zone.sh