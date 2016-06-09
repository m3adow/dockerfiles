FROM m3adow/alpine_dumb-init_gosu
MAINTAINER Till Wiese <mail-github.com@till-wiese.de>

RUN apk add --no-cache curl python py-pip py-imaging py-mysqldb \
    gcc python-dev musl-dev openldap-dev bash \ 
  && pip install python-memcached python-ldap # pil-compat

RUN mkdir -p /srv/seafile/conf \
  && curl -sL $(curl -sL https://www.seafile.com/en/download/ \
    | grep -oE 'https://.*seafile-server.*x86-64.tar.gz'|sort -r|head -1) \
    | tar -C /tmp/ -xz \
  && mv /tmp/seafile-server* /srv/seafile/server
