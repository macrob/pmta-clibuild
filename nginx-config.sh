#!/bin/bash

nginxPth=/etc/nginx;
# nginxPth=/Users/mac/private/wwwmac/pmta-clibuild/test;
mkdir -p /var/www/_letsencrypt;
chown nginx /var/www/_letsencrypt

mkdir ${nginxPth}/sites-available;
mkdir ${nginxPth}/sites-enabled;
cp -R nginx/nginxconfig.io ${nginxPth}/;
cp nginx/dhparam.pem ${nginxPth}/;
cp nginx/nginx.conf ${nginxPth}/;




while getopts d: flag
do
    case "${flag}" in
        d) domain=${OPTARG};;
    esac
done

if test -z "$domain" 
then
      echo " -d is empty: example '-d mydomain'"
      exit;
fi

cp nginx/sites-enabled/trackdomain.conf ${nginxPth}/sites-enabled/${domain}.conf;


sed -i -r "s/trackdomain/${domain}/g" ${nginxPth}/sites-enabled/${domain}.conf;
rm ${nginxPth}/sites-enabled/${domain}.conf-r;

sed -i -r 's/(listen .*443)/\1; #/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g; s/(server \{)/\1\n    ssl off;/g' ${nginxPth}/sites-enabled/${domain}.conf;
sudo nginx -t && sudo systemctl reload nginx;

#sed -i -r 's/ssl_certificate/#ssl_certificate/g' ${nginxPth}/sites-enabled/${domain}.conf
#sed -i -r 's/# include snippets\/self/ include snippets\/self/g' ${nginxPth}/sites-enabled/${domain}.conf
#sed -i -r 's/# include snippets\/ssl/ include snippets\/ssl/g' ${nginxPth}/sites-enabled/${domain}.conf

certbot certonly --webroot -d ${domain} --email cfl@xambo.io -w /var/www/_letsencrypt -n --agree-tos --force-renewal


sed -i -r -z 's/#?; ?#//g; s/(server \{)\n    ssl off;/\1/g' ${nginxPth}/sites-enabled/${domain}.conf;
sudo nginx -t && sudo systemctl reload nginx;
echo -e '#!/bin/bash\nnginx -t && systemctl reload nginx' | sudo tee /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh;
sudo chmod a+x /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh;

#echo ${domain}.conf;