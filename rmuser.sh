#!/bin/sh

VPN_USER="$1"

if [ -z "$VPN_USER" ]; then
  echo "Usage: $0 username" >&2
  echo "Example: $0 jordi" >&2
  exit 1
fi

cp /usr/local/etc/ipsec.secrets /usr/local/etc/ipsec.secrets.bak
sed "/$VPN_USER :/d" /usr/local/etc/ipsec.secrets.bak > /usr/local/etc/ipsec.secrets

ipsec rereadsecrets