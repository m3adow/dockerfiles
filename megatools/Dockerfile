FROM debian:sid
MAINTAINER Till Wiese <mail-hub.docker.com@till-wiese.de>

RUN apt-get update \
	&& apt-get install --yes megatools \
	&& rm -rf /var/lib/apt/lists/* \
	&& groupadd -r mega \
	&& useradd -r -g mega mega \
	&& mkdir -m 755 /mega \
	&& chown mega:mega /mega

USER mega
