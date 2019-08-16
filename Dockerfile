FROM ubuntu:bionic as main
LABEL maintainer="Troy Kinsella <troy.kinsella@gmail.com>"

ADD https://github.com/docker/compose/releases/download/1.24.1/docker-compose-linux-x86_64 /usr/local/bin/docker-compose

RUN set -eux; \
    chmod +x /usr/local/bin/docker-compose; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      curl \
      gnupg \
      jq; \
    \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -; \
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" >> /etc/apt/sources.list; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      docker-ce-cli; \
    DEBIAN_FRONTEND=noninteractive apt-get remove -y \
      gnupg \
      curl; \
    DEBIAN_FRONTEND=noninteractive apt-get autoremove -y; \
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
    cp /usr/local/bin/mockleton /usr/bin/docker; \
    cp /usr/local/bin/mockleton /usr/local/bin/docker-compose;

COPY . /resource/

RUN set -eux; \
    cd /resource; \
    rspec


FROM main
