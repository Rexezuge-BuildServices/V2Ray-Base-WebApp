FROM rexezugedockerutils/cloudflared AS cloudflared

FROM rexezugedockerutils/upx AS upx

FROM debian:12 AS builder

WORKDIR /tmp

# Install Dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential curl unzip zlib1g-dev libpcre2-dev perl ca-certificates

COPY --from=upx /upx /usr/local/bin/upx

# Download V2Ray and Compress
RUN curl -L -o /tmp/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip \
 && unzip /tmp/v2ray.zip -d /tmp/v2ray \
 && upx --best --lzma /tmp/v2ray/v2ray

# Generate Random Self Signed SSL Certificate
RUN mkdir -p /tmp/ssl/selfsigned \
 && openssl req -x509 -newkey rsa:2048 -days 365 -nodes -keyout /tmp/ssl/selfsigned/server.key -out /tmp/ssl/selfsigned/server.crt -subj "/CN=localhost"

FROM rexezugedockerutils/nginx-static AS nginx-static

FROM rexezugedockerutils/nginx-uptime-go AS nginx-uptime-go

FROM rexezugedockerutils/usagi-init:release AS runtime

COPY --from=builder /tmp/v2ray/v2ray /usr/local/bin/v2ray

COPY --from=cloudflared /cloudflared /usr/local/bin/cloudflared

COPY --from=builder /tmp/ssl/selfsigned /etc/ssl/selfsigned

COPY --from=nginx-static /nginx /usr/sbin/nginx

COPY --from=nginx-uptime-go /NginxUptime-Go /NginxUptime-Go

COPY overlay/ /

FROM scratch

COPY --from=runtime / /

ENTRYPOINT ["/UsagiInit"]
