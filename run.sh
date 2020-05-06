#!/bin/bash

VPNIPPOOL="10.15.1.0/24"
LEFT_ID=${VPNHOST}

sysctl net.ipv4.ip_forward=1
sysctl net.ipv6.conf.all.forwarding=1
sysctl net.ipv6.conf.eth0.proxy_ndp=1

if [ ! -z "$DNS_SERVERS" ] ; then
DNS=$DNS_SERVERS
else
DNS="1.1.1.1,8.8.8.8"
fi

if [ ! -z "$SPEED_LIMIT" ] ; then
tc qdisc add dev eth0 handle 1: ingress
tc filter add dev eth0 parent 1: protocol ip prio 1 u32 match ip src 0.0.0.0/0 police rate ${SPEED_LIMIT}mbit burst 10k drop flowid :1
tc qdisc add dev eth0 root tbf rate ${SPEED_LIMIT}mbit latency 25ms burst 10k
fi

iptables -t nat -A POSTROUTING -s ${VPNIPPOOL} -o eth0 -m policy --dir out --pol ipsec -j ACCEPT
iptables -t nat -A POSTROUTING -s ${VPNIPPOOL} -o eth0 -j MASQUERADE

iptables -L

if [[ ! -f "/usr/local/etc/ipsec.d/certs/fullchain.pem" && ! -f "/usr/local/etc/ipsec.d/private/privkey.pem" ]] ; then
    certbot certonly --standalone --preferred-challenges http --agree-tos --no-eff-email --email ${LEEMAIL} -d ${VPNHOST}
    cp /etc/letsencrypt/live/${VPNHOST}/fullchain.pem /usr/local/etc/ipsec.d/certs
    cp /etc/letsencrypt/live/${VPNHOST}/privkey.pem /usr/local/etc/ipsec.d/private
    cp /etc/letsencrypt/live/${VPNHOST}/chain.pem /usr/local/etc/ipsec.d/cacerts
fi

rm -f /var/run/starter.charon.pid

if [ -f "/usr/local/etc/ipsec.conf" ]; then
rm /usr/local/etc/ipsec.conf
cat >> /usr/local/etc/ipsec.conf <<EOF
config setup
    charondebug="ike 1, knl 1, cfg 1"
    uniqueids=never
conn ikev2-vpn
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    ike=aes128-sha1-modp1024,aes128-sha1-modp1536,aes128-sha1-modp2048,aes128-sha256-ecp256,aes128-sha256-modp1024,aes128-sha256-modp1536,aes128-sha256-modp2048,aes256-aes128-sha256-sha1-modp2048-modp4096-modp1024,aes256-sha1-modp1024,aes256-sha256-modp1024,aes256-sha256-modp1536,aes256-sha256-modp2048,aes256-sha256-modp4096,aes256-sha384-ecp384,aes256-sha384-modp1024,aes256-sha384-modp1536,aes256-sha384-modp2048,aes256-sha384-modp4096,aes256gcm16-aes256gcm12-aes128gcm16-aes128gcm12-sha256-sha1-modp2048-modp4096-modp1024,3des-sha1-modp1024!
    esp=aes128-aes256-sha1-sha256-modp2048-modp4096-modp1024,aes128-sha1,aes128-sha1-modp1024,aes128-sha1-modp1536,aes128-sha1-modp2048,aes128-sha256,aes128-sha256-ecp256,aes128-sha256-modp1024,aes128-sha256-modp1536,aes128-sha256-modp2048,aes128gcm12-aes128gcm16-aes256gcm12-aes256gcm16-modp2048-modp4096-modp1024,aes128gcm16,aes128gcm16-ecp256,aes256-sha1,aes256-sha256,aes256-sha256-modp1024,aes256-sha256-modp1536,aes256-sha256-modp2048,aes256-sha256-modp4096,aes256-sha384,aes256-sha384-ecp384,aes256-sha384-modp1024,aes256-sha384-modp1536,aes256-sha384-modp2048,aes256-sha384-modp4096,aes256gcm16,aes256gcm16-ecp384,3des-sha1!
    fragmentation=yes
    forceencaps=yes
    dpdaction=clear
    dpddelay=300s
    rekey=no
    left=%any
    leftid=@$LEFT_ID
    leftcert=fullchain.pem
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    leftupdown=/etc/strongswan-updown.sh
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightsourceip=10.15.1.0/24
    rightdns=$DNS
    rightsendcert=never
    eap_identity=%identity
EOF
fi

if [ ! -f "/usr/local/etc/ipsec.secrets" ]; then
cat > /usr/local/etc/ipsec.secrets <<EOF
: RSA privkey.pem
EOF
fi

if [[ ! -z "$RADIUS_SERVER" && ! -z "$RADIUS_SERVER_SECRET" ]]; then
rm /usr/local/etc/strongswan.d/charon/eap-radius.conf
cat >> /usr/local/etc/strongswan.d/charon/eap-radius.conf <<EOF
eap-radius {
    accounting = yes
    accounting_close_on_timeout = no
    close_all_on_timeout = no
    load = yes
    nas_identifier = $VPNHOST

    # Section to specify multiple RADIUS servers.
    servers {
        server-a {
            address = $RADIUS_SERVER
            secret = $RADIUS_SERVER_SECRET
            auth_port = 1812   # default
            acct_port = 1813   # default
        }
    }
}
EOF
fi
sysctl -p

ipsec start --nofork
