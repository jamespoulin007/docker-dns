FROM ubuntu:18.04 AS add-webmin-src

LABEL Maintainer="James Poulin"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg \
    && apt-key adv --fetch-keys http://www.webmin.com/jcameron-key.asc \
    && echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
        
FROM ubuntu:18.04

LABEL Maintainer="James Poulin"

ENV BIND_USER=bind \
    BIND_VERSION=9.11.3 \
    WEBMIN_VERSION=1.9 \
    DATA_DIR=/data \
    TINI_VERSION=v0.18.0

COPY --from=add-webmin-src /etc/apt/trusted.gpg /etc/apt/trusted.gpg

COPY --from=add-webmin-src /etc/apt/sources.list /etc/apt/sources.list

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

RUN set -e \
    && rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -yq \
        less \
        nano \
        bind9=1:${BIND_VERSION}* \
        bind9utils=1:${BIND_VERSION}* \
        dnsutils \
        webmin=${WEBMIN_VERSION}*  

RUN chmod +x /tini

COPY launch.sh /

RUN chmod +x /launch.sh

EXPOSE 53/udp 53/tcp 10000/tcp

ENTRYPOINT ["/tini", "--"]

CMD ["/launch.sh"]



