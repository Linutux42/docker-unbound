#!/bin/sh
set -m

/bin/bash /unbound-refresher.sh

service cron start

/usr/sbin/unbound -v -c /etc/unbound/unbound.conf

while inotifywait --event close_write,moved_to,create,modify /etc/unbound/;
  do kill -HUP `cat /var/run/unbound/unbound.pid`;
done
