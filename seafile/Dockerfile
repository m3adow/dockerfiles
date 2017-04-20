FROM m3adow/ubuntu_dumb-init_gosu:latest
MAINTAINER Till Wiese <mail-github.com@till-wiese.de>

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && apt-get install -y python2.7 libpython2.7 python-mysqldb \
      python-setuptools python-imaging python-ldap sqlite3 \
      python-memcache curl ack-grep \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ["install.sh", "/tmp/"]
RUN /tmp/install.sh

COPY ["seafile-entrypoint.sh", "/usr/local/bin/"]

EXPOSE 8000 8082

ENTRYPOINT ["/usr/bin/dumb-init", "/usr/local/bin/seafile-entrypoint.sh"]
