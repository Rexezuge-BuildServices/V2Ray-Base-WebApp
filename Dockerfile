FROM rexezugedockerutils/upx AS upx

FROM debian:12 AS builder

WORKDIR /tmp

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl unzip ca-certificates

COPY --from=upx /upx /usr/local/bin/upx

# Download V2Ray and Compress
RUN curl -L -o /tmp/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip \
 && unzip /tmp/v2ray.zip -d /tmp/v2ray \
 && upx --best --lzma /tmp/v2ray/v2ray

FROM rexezugebuild/appservicelauncher AS runtime

COPY --from=builder /tmp/v2ray/v2ray /usr/local/bin/v2ray

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

FROM scratch

COPY --from=runtime / /

ENTRYPOINT ["/.AppServiceLauncher/launcher.sh"]

CMD ["/usr/local/bin/v2ray", "run", "-config", "/etc/v2ray/config.json"]
