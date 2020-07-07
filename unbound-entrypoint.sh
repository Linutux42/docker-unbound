#!/bin/bash
#
# Using blacklist from pi-hole project https://github.com/pi-hole/
# to enable AD blocking in unbound(8)
#
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

# Available blocklists - comment line to disable blocklist
_disconad="https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
_discontrack="https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
_hostfiles="https://hosts-file.net/ad_servers.txt"
_malwaredom="https://mirror1.malwaredomains.com/files/justdomains"
_stevenblack="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
_zeustracker="https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist"

# Root hints from internic
_roothints="https://www.internic.net/domain/named.root"

# Global variables
_tmpfile="$(mktemp)" && echo '' > $_tmpfile
_basedir="/etc/unbound"
_unboundconf="${_basedir}/unbound.conf.d/unbound-adhosts.conf"

function _print_status {
  if [ "${1}" -eq "0" ]; then
    echo "OK"
  else
    echo "FAILED"
  fi
}

# Remove comments from blocklist
function simpleParse {
  echo "Downloading and parsing ${1} ... "
  curl -s $1 | \
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' >> $2
  _print_status "${?}"
}

# Make sure folder unbound.conf.d exists
[[ ! -d "${_basedir}/unbound.conf.d" ]] && mkdir ${_basedir}/unbound.conf.d

# Parse MalwareDom
[[ -n ${_malwaredom+x} ]] && simpleParse $_malwaredom $_tmpfile

# Parse ZeusTracker
[[ -n ${_zeustracker+x} ]] && simpleParse $_zeustracker $_tmpfile

# Parse DisconTrack
[[ -n ${_discontrack+x} ]] && simpleParse $_discontrack $_tmpfile

# Parse DisconAD
[[ -n ${_disconad+x} ]] &&  simpleParse $_disconad $_tmpfile

# Parse StevenBlack
[[ -n ${_stevenblack+x} ]] && \
  echo "Downloading and parsing ${1} ... " && \
  curl -s $_stevenblack | \
  sed -n '/Start/,$p' | \
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' | \
  awk '/^0.0.0.0/ { print $2 }' >> $_tmpfile && \
  _print_status "${?}"

# Parse hpHosts
[[ -n ${_hostfiles+x} ]] && \
  echo "Downloading and parsing ${1} ... " && \
  curl -s $_hostfiles | \
  sed -n '/START/,$p' | tr -d '^M$' | \
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' -e 's/$//' | \
  awk '/^127.0.0.1/ { print $2 }' >> $_tmpfile && \
  _print_status "${?}"

# Create unbound(8) local zone file
echo "Merging ... "
echo 'server:' > $_unboundconf && \
  sort -fu $_tmpfile | \
  grep -v "^[[:space:]]*$" | \
awk '{
print "local-zone: \"" $1 "\" static"
}' >> $_unboundconf && rm -f $_tmpfile
_print_status "${?}"

# Download latest root.hints
echo -n "Downloading root.hints from internic ... "
curl -so ${_basedir}/root.hints $_roothints
_print_status "${?}"

# Update DNSSEC root key
echo -n "Downloading root anchors ... "
unbound-anchor -v
_print_status "${?}"

# Start unbound
/usr/sbin/unbound -d -v -c /etc/unbound/unbound.conf

exit ${?}
#EOF
