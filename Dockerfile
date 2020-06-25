FROM debian:buster-slim

COPY unbound-entrypoint.sh /

RUN apt-get update && apt-get install -y unbound && rm -rf /var/lib/apt/lists/*

USER nobody

EXPOSE 53

ENTRYPOINT [ "sh", "/unbound-entrypoint.sh" ]
