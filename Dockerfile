# https://docs.docker.com/engine/articles/dockerfile_best-practices/ 
FROM joaoportela/python3-nosetests
MAINTAINER JP <jportela@abyssal.eu>

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
# also install curl because it is needed to download installation scripts and all that.
# and gnupg for (repositories) keys management.
RUN apt-get -yq update && apt-get --no-install-recommends -yq install locales curl gnupg \
	&& rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# install rabbitmq - which will also install erlang
RUN apt-get -yq update && apt-get --no-install-recommends -yq install rabbitmq-server

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

# install postgresql
# may install tzdata, which needs DEBIAN_FRONTEND and DEBCONF_NONINTERACTIVE_SEEN (see note1)
RUN apt-get -yq update \
&& DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
	apt-get --no-install-recommends -yq install \
	postgresql-10 \
	postgresql-10-postgis-2.4 \
	postgresql-10-postgis-2.4-scripts \
	postgresql-contrib-10 \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# note1: this may install tzdata as a dependency which has interactive
# operations for the timezone selection. we must disable it or we cannot
# build the image (and the default 'Etc/UTC' is the correct timezone).

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data

