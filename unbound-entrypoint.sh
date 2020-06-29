#!/bin/sh

/usr/sbin/unbound -v -c /etc/unbound/unbound.conf

while inotifywait --event close_write,moved_to,create,modify /etc/unbound/;
  do kill -HUP `cat /var/run/unbound/unbound.pid`;
done
