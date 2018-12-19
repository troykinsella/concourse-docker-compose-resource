FROM ubuntu:bionic as main
LABEL maintainer="Troy Kinsella <troy.kinsella@gmail.com>"

ADD https://github.com/docker/compose/releases/download/1.23.1/docker-compose-linux-x86_64 /usr/local/bin/docker-compose

RUN set -eux; \
    chmod +x /usr/local/bin/docker-compose; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      jq; \
    apt-get clean all; \
    rm -rf /var/lib/apt/lists/*

COPY assets/* /opt/resource/

FROM main as testing

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ruby \
      wget; \
    gem install \
      rspec; \
    wget -q -O - https://raw.githubusercontent.com/troykinsella/mockleton/master/install.sh | bash; \
    cp /usr/local/bin/mockleton /usr/local/bin/docker-compose

COPY . /resource/

RUN set -eux; \
    cd /resource; \
    rspec


FROM main
