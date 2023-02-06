FROM debian:bullseye-slim

COPY unbound-entrypoint.sh /

# hadolint ignore =DL3008
RUN apt-get update \
  && apt-get install -y unbound curl --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /etc/unbound/*

VOLUME /etc/unbound/

ENTRYPOINT [ "/bin/bash", "/unbound-entrypoint.sh" ]
