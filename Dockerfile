FROM debian:bullseye-slim AS builder

# hadolint ignore=DL3008
RUN apt-get update\
  && apt-get install -y unbound curl ca-certificates --no-install-recommends

COPY setup-unbound.sh /
RUN bash /setup-unbound.sh

FROM debian:bullseye-slim AS final

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y unbound --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /etc/unbound/*

USER unbound

COPY --from=builder --chown=unbound:unbound /etc/unbound/ /etc/unbound/
COPY --from=builder --chown=unbound:unbound /var/lib/unbound/root.key /var/lib/unbound/root.key
COPY --chown=unbound:unbound server.conf /etc/unbound/unbound.conf.d/server.conf

ENTRYPOINT ["/usr/sbin/unbound", "-d", "-v", "-p"]
