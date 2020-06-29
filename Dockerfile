FROM debian:buster-slim

COPY unbound-entrypoint.sh /

RUN apt-get update \
  && apt-get install -y unbound inotify-tools \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /etc/unbound/*

VOLUME /etc/unbound/

EXPOSE 53

ENTRYPOINT [ "sh", "/unbound-entrypoint.sh" ]
