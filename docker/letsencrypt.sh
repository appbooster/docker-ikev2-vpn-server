#!/bin/sh

certbot certonly --standalone --preferred-challenges http --agree-tos --no-eff-email --email ${LEEMAIL} -d ${VPNHOST}
cp /etc/letsencrypt/live/${VPNHOST}/fullchain.pem /usr/local/etc/ipsec.d/certs
cp /etc/letsencrypt/live/${VPNHOST}/privkey.pem /usr/local/etc/ipsec.d/private
curl https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem --output /usr/local/etc/ipsec.d/cacerts/lets-encrypt-x3-cross-signed.pem

ipsec restart