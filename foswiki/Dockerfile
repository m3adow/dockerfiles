FROM nginx:alpine

MAINTAINER Till Wiese <mail-github.com@till-wiese.de>

RUN apk add --no-cache diffutils grep perl-fcgi \
  perl-fcgi-procmanager ca-certificates \
  && wget -O /tmp/latest.tar.gz \
  https://sourceforge.net/projects/foswiki/files/latest/download
