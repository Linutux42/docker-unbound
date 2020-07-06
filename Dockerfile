FROM debian:buster-slim

COPY unbound-entrypoint.sh /
COPY unbound-refresher.sh /

RUN apt-get update \
  && apt-get install -y unbound inotify-tools curl cron \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /etc/unbound/unbound_* \
  && rm -rf /etc/cron.daily \
  && echo "00 05 * * * root /bin/bash /unbound-refresher.sh" >/etc/cron.d/unbound-ads-refresh

VOLUME /etc/unbound

ENTRYPOINT [ "sh", "/unbound-entrypoint.sh" ]
