#!/bin/sh

VPN_USER="$1"

if [ -z "$VPN_USER" ]; then
  echo "Usage: $0 username" >&2
  echo "Example: $0 jordi" >&2
  exit 1
fi

case "$VPN_USER" in
  *[\\\"\']*)
    echo "VPN credentials must not contain any of these characters: \\ \" '" >&2
    exit 1
    ;;
esac

VPN_PASSWORD="$(openssl rand -base64 9)"
HOST="$(printenv VPNHOST)"

echo "Password for user is: $VPN_PASSWORD"
echo $VPN_USER : EAP \"$VPN_PASSWORD\">> /usr/local/etc/ipsec.secrets

ipsec rereadsecrets
