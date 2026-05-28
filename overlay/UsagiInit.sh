#!/UsagiInit
mkdir -p /tmp/nginx/logs
/ChordDHT-Node -tls-cert /tmp/ssl/selfsigned/server.crt -tls-key /tmp/ssl/selfsigned/server.key > /dev/null &
/usr/local/bin/cloudflared tunnel --no-autoupdate run --token $CLOUDFLARE_TOKEN > /dev/null &
/usr/local/bin/v2ray run -config /etc/v2ray/config.json > /dev/null &
/usr/sbin/nginx -p /tmp/nginx -c /etc/nginx/nginx.conf -g "daemon off;" > /dev/null &
