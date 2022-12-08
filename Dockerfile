FROM docker/compose:latest as main
LABEL maintainer="Troy Kinsella <troy.kinsella@gmail.com>"

RUN set -eux; \
    apk update; \
    apk upgrade; \
    apk add bash ca-certificates jq; \
    rm -rf /var/cache/apk/*;

COPY assets/* /opt/resource/

FROM main as testing

RUN set -eux; \
    apk update; \
    apk add ruby ruby-json wget; \
    gem install rspec; \
    wget -q -O - https://raw.githubusercontent.com/troykinsella/mockleton/master/install.sh | bash; \
    cp /usr/local/bin/mockleton /usr/bin/docker; \
    cp /usr/local/bin/mockleton /usr/local/bin/docker-compose; \
    rm -rf /var/cache/apk/*;

COPY . /resource/

RUN set -eux; \
    cd /resource; \
    rspec;

FROM main
