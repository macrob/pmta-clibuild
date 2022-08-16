#!/bin/bash
yum install -y jq;

domain=`jq -r .domain config.json`;
primaryIp=`jq -r .ip[0] config.json`;
ips=`jq -r .ip[] config.json`;

echo $primaryIp;
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

####  GENERATE dkim
echo "Генерация dkim"

mkdir -p $dkimDir;

dkimKeyPth="${dkimDir}/dkim5.${domain}.key";
dkimPubPth="${dkimDir}/dkim5.${domain}.pub";

openssl genrsa -out $dkimKeyPth 2048
openssl rsa -in $dkimKeyPth -pubout > $dkimPubPth;
chmod 0444 $dkimKeyPth;
dkim=`cat $dkimPubPth | sed '/^-/d' | awk '{printf "%s", $1}'`
dkimRecord=`echo "v=DKIM1; k=rsa; p=${dkim}" | sed -r 's/.{60}/&" "/g'`;
#dkimRecord=`echo "v=DKIM1; k=rsa; p=${dkim}"`;


#####  ZONE FILE
mkdir -p $zones;
zoneFile="${zones}/${domain}.zone"
serial=`date +%Y%m%d00`

#dkim=$(cat /etc/pmta/dkim/public_key_${domain[0]}.txt)
touch $zoneFile;

spfip=""
for ip in $ips; do
  spfip+="ip4:"${ip}" ";
done

cat > $zoneFile <<EOL
\$ORIGIN .
\$TTL 86400
${domain}         IN      SOA             ns1.${domain}.        it.${domain}. (
                                  ${serial} ; serial
                                  300 ; refresh after 6 hours
                                  600 ; retry after 1 hour
                                  4800 ; expire after 1 week
                                  86400 )         ; minimum TTL of 1 day

                  IN    NS    ns1.${domain}.
                  IN    NS    ns2.${domain}.

                  IN    MX    10 mail.${domain}.
ns1.${domain}.    IN    A    ${primaryIp}
ns2.${domain}.    IN    A    ${primaryIp}
${domain}.        IN    A    ${primaryIp}
www.${domain}.    IN    A    ${primaryIp}
smtp.${domain}.   IN    A    ${primaryIp}
pop.${domain}.    IN    A    ${primaryIp}
imap.${domain}.   IN    A    ${primaryIp}
mail.${domain}.   IN    A    ${primaryIp}
track.${domain}.   IN    A    ${primaryIp}
${domain}.        IN    TXT    "v=spf1 ${spfip} a mx ~all"
dkim5._domainkey.${domain}.   IN    TXT    "$dkimRecord"
_adsp._domainkey.${domain}.   IN    TXT    "dkim=all"
_dmarc._domainkey.${domain}.  IN    TXT    "v=DMARC1; p=reject; adkim=s; aspf=s;"
EOL

for ip in $ips; do
  while IFS='.' read -ra ipSplit; do
    server="s${ipSplit[3]}";
    echo "${server}.${domain}.    IN    A    ${ip}" >> $zoneFile
  done <<< "$ip"
done

echo "Bind DNS install successful"

systemctl enable named && systemctl restart named
