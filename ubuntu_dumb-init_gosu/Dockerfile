FROM ubuntu:latest

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates
RUN cd /tmp/ \
  && curl -sLO $(curl -s https://api.github.com/repos/yelp/dumb-init/releases/latest \
    | awk '/browser_download_url/ { print $2 }' \
    | sed 's/"//g'|grep -m 1 -E '\.deb$') \
  && curl -sLO $(curl -s https://api.github.com/repos/yelp/dumb-init/releases/latest \
    | awk '/browser_download_url/ { print $2 }' \
    | sed 's/"//g'|grep sha256sums) \
  && sha256sum -c ./sha256sums --ignore-missing --quiet \
  && dpkg -i ./*dumb-init*.deb \
  && rm -f ./sha256sums ./*dumb-init*

RUN cd /usr/local/bin \
  && curl -sLO $(curl -s https://api.github.com/repos/tianon/gosu/releases/latest \
    | awk '/browser_download_url/ { print $2 }' \
    | sed 's/"//g'|grep -E "gosu-$(dpkg --print-architecture)\$") \
  && curl -sLO $(curl -s https://api.github.com/repos/tianon/gosu/releases/latest \
    | awk '/browser_download_url/ { print $2 }' \
    | sed 's/"//g'|grep -E 'SHA256SUMS$') \
  && sha256sum -c ./SHA256SUMS --ignore-missing --quiet \
  && mv gosu-$(dpkg --print-architecture) gosu \
  && chmod +x gosu \
  && rm -f SHA256SUMS
RUN DEBIAN_FRONTEND=noninteractive apt-get purge -y curl ca-certificates \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/log/*
