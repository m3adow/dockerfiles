FROM m3adow/ubuntu_dumb-init_gosu:latest
MAINTAINER Till Wiese <mail-github.com@till-wiese.de>

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && apt-get install -y python2.7 libpython2.7 python-mysqldb \
      python-setuptools python-imaging python-ldap sqlite3 \
      python-memcache curl

RUN mkdir -p /opt/haiwen \
  && curl -sL $(curl -sL https://www.seafile.com/en/download/ \
    | grep -oE 'https://.*seafile-server.*x86-64.tar.gz'|sort -r|head -1) \
    | tar -C /opt/haiwen/ -xz \
  && mkdir -p /seafile/conf /seafile/seafile-data \
    /seafile/seahub-data \
  && ln -s /seafile/conf /opt/haiwen/conf \
  && ln -s /seafile/seafile-data /opt/haiwen/seafile-data \
  && ln -s /seafile/seahub-data /opt/haiwen/seahub-data \
  && ln -s /opt/haiwen/$(ls -1 /opt/haiwen/ \
    | grep -E '^seafile-server-[0-9.-]+') /opt/haiwen/seafile-server-latest

COPY ["seafile-entrypoint.sh", "/usr/local/bin/"]

EXPOSE 8000 8082

ENTRYPOINT ["/usr/bin/dumb-init", "/usr/local/bin/seafile-entrypoint.sh"]
