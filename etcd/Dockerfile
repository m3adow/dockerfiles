FROM alpine:latest
MAINTAINER Till Wiese <mail-github.com@till-wiese.de>

RUN apk add --no-cache bash curl ca-certificates && \
  curl -sL $(curl -s https://api.github.com/repos/coreos/etcd/releases/latest \
    | grep -E '"browser_download_url.*etcd-.*-linux-amd64.tar.gz"' | cut -d\" -f4) | tar -C /tmp -xz \
  && mv /tmp/etcd-*-linux-amd64/etcd* /usr/local/bin/ \
  && chmod 755 /usr/local/bin/etcd* \
  && curl -sLo /usr/local/bin/giddyup $(curl -s https://api.github.com/repos/cloudnautique/giddyup/releases/latest \
    | grep -E '"browser_download_url.*giddyup"'| head -1 | cut -d\" -f4) \
  && chmod 755 /usr/local/bin/giddyup

# Scripts are taken from https://github.com/rancher/catalog-dockerfiles/tree/master/etcd/containers/0.9.0/etcd
COPY run.sh /run.sh
COPY disaster /usr/bin/disaster

ENTRYPOINT ["/run.sh"]
CMD ["node"]
