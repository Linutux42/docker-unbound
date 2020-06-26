FROM debian:buster-slim

COPY unbound-entrypoint.sh /

RUN apt-get update && apt-get install -y unbound inotify-tools && rm -rf /var/lib/apt/lists/*

USER nobody

EXPOSE 5353

ENTRYPOINT [ "sh", "/unbound-entrypoint.sh" ]
