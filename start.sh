#!/bin/sh

docker run \
    --name ikev2-vpn-server \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -p 80:80 \
    -v /lib/modules:/lib/modules:ro \
    --cap-add=NET_ADMIN \
    -v "$PWD/data/certs/certs:/usr/local/etc/ipsec.d/certs" \
    -v "$PWD/data/certs/private:/usr/local/etc/ipsec.d/private" \
    -v "$PWD/data/certs/cacerts:/usr/local/etc/ipsec.d/cacerts" \
    -v "$PWD/data/etc/ipsec.d/ipsec.secrets:/usr/local/etc/ipsec.secrets" \
    --env-file "$PWD/.env" \
    -v /lib/modules:/lib/modules:ro \
    -d --privileged \
    --restart=always \
    drzhnin/docker-ikev2-vpn-server
