#!/bin/sh

VPNHOST="$1"
LEEMAIL="$2"

if [ -z "$VPNHOST" ] ||[ -z "$LEEMAIL" ]; then
  echo "Usage: $0 domain email" >&2
  echo "Example: $0 vpn.example.com user@email.com" >&2
  exit 1
fi

docker run \
    --name ikev2-vpn-server \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -p 80:80 \
    -v /lib/modules:/lib/modules:ro \
    - v ./data:/usr/local/etc \
    --env VPNHOST=$VPNHOST \
    --env LEEMAIL=$LEEMAIL \
    -d --privileged \
    --restart=always \
    drzhnin/docker-ikev2-vpn-server