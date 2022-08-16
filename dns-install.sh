
echo "Установка Bind(named) DNS"
yum -y install bind bind-utils >/dev/null 2>/dev/null
mv /etc/named.conf /etc/named.conf.orig
touch /etc/named.conf
cat << 'EOF' > /etc/named.conf
options {
#       listen-on port 53 { 127.0.0.1; };
#        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { any; };
        allow-transfer  { localhost; };
        recursion no;
        dnssec-enable yes;
        dnssec-validation yes;

        /* Path to ISC DLV key */
        bindkeys-file "/etc/named.iscdlv.key";

        managed-keys-directory "/var/named/dynamic";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
EOF


ufw allow 53/tcp comment 'Open port DNS tcp port 53'
ufw allow 53/udp comment 'Open port DNS udp port 53'