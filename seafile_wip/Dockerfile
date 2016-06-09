FROM m3adow:alpine_dumb-init_gosu
MAINTAINER Till Wiese <mail-github.com@till-wiese.de>

RUN apk add --no-cache curl python py-pip \
  && pip install python-memcached python-ldap PIL

RUN mkdir -p /srv/seafile \
  && curl -sL $(curl -sL https://www.seafile.com/en/download/ \
    | grep -oE 'https://.*seafile-server.*x86-64.tar.gz'|sort -r|head -1) \
    | tar -C /tmp -xz
