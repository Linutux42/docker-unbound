FROM debian:buster-slim

COPY unbound-entrypoint.sh /
COPY unbound-ads-refresh.sh /

RUN apt-get update \
  && apt-get install -y unbound inotify-tools curl cron \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /etc/unbound/* \
  && rm -rf /etc/cron.daily \
  && mkdir /etc/unbound/unbound.conf.d/ \
  && echo "00 05 * * * root /bin/bash /unbound-ads-refresh.sh" >/etc/cron.d/unbound-ads-refresh \
  && echo "10 05 * * * unbound /bin/curl -so /etc/unbound/root.hints https://www.internic.net/domain/named.root" >/etc/cron.d/unbound-update-root-hints

EXPOSE 53

ENTRYPOINT [ "sh", "/unbound-entrypoint.sh" ]
