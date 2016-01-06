# https://docs.docker.com/engine/articles/dockerfile_best-practices/ 
FROM joaoportela/python3-nosetests
MAINTAINER JP <jportela@abyssal.eu>

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
# also install curl because it is needed to download installation scripts and all that.
RUN apt-get -yq update && apt-get -yq install locales curl \
	&& rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# add erlang repo keys
RUN FILE=`mktemp` && curl -s -o$FILE http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
	&& dpkg -i $FILE; rm $FILE

# add rabbitmq repo keys
COPY rabbitmq-add-repo-keys.sh /tmp/rabbitmq-add-repo-keys.sh
RUN /tmp/rabbitmq-add-repo-keys.sh

# install rabbitmq - which will also install erlang
RUN apt-get -yq update && apt-get -yq install rabbitmq-server \
	&& rm -rf /var/lib/apt/lists/*

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

# install postgresql
RUN apt-get -yq update && apt-get -yq install \
        postgresql-9.4 \
	postgresql-contrib-9.4 \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*


RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data

