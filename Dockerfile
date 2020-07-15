FROM debian:buster-slim

COPY unbound-entrypoint.sh /

RUN apt-get update \
  && apt-get install -y unbound curl \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /etc/unbound/*

VOLUME /etc/unbound/

ENTRYPOINT [ "/bin/bash", "/unbound-entrypoint.sh" ]
