FROM alpine:latest

ENV VPNHOST ''
ENV LEEMAIL ''
ENV TZ=Europe/Moscow

# strongSwan Version
ARG SS_VERSION="https://download.strongswan.org/strongswan-5.8.2.tar.gz"
ARG BUILD_DEPS="gettext"
ARG RUNTIME_DEPS="libintl"

# Install dep packge , Configure,make and install strongSwan
RUN apk --update add build-base curl bash iproute2 iptables-dev openssl openssl-dev supervisor bash certbot \
    && mkdir -p /tmp/strongswan \
    && apk add --update $RUNTIME_DEPS \
    && apk add --virtual build_deps $BUILD_DEPS \
    && cp /usr/bin/envsubst /usr/local/bin/envsubst \
    && curl -Lo /tmp/strongswan.tar.gz $SS_VERSION \
    && tar --strip-components=1 -C /tmp/strongswan -xf /tmp/strongswan.tar.gz \
    && cd /tmp/strongswan \
    && ./configure  --enable-eap-identity --enable-eap-md5 --enable-eap-mschapv2 --enable-eap-tls --enable-eap-ttls --enable-eap-peap --enable-eap-tnc --enable-eap-dynamic --enable-xauth-eap --enable-dhcp --enable-openssl --enable-addrblock --enable-unity --enable-certexpire --enable-radattr --enable-swanctl --enable-eap-radius --disable-gmp && make && make install \
    && rm -rf /tmp/* \
    && apk del build-base openssl-dev build_deps \
    && rm -rf /var/cache/apk/* \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && rm /usr/local/etc/ipsec.secrets

COPY ./run.sh /run.sh
COPY ./adduser.sh /adduser.sh
COPY ./rmuser.sh /rmuser.sh

RUN chmod 755 /run.sh /adduser.sh /rmuser.sh

VOLUME ["/usr/local/etc/ipsec.secrets"]

EXPOSE 500:500/udp 4500:4500/udp

CMD ["/run.sh"]