# https://docs.docker.com/engine/articles/dockerfile_best-practices/ 
FROM joaoportela/python3-nosetests
MAINTAINER JP <jportela@abyssal.eu>
RUN apt-get -yq update && apt-get install -yq curl
# add erlang repo keys
RUN FILE=`mktemp` && curl -s -o$FILE http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && dpkg -i $FILE; rm $FILE
# add rabbitmq repo keys
COPY rabbitmq-add-repo-keys.sh /tmp/rabbitmq-add-repo-keys.sh
RUN /tmp/rabbitmq-add-repo-keys.sh

# install rabbitmq - which will also install erlang.
RUN apt-get -yq update && apt-get -yq install \
    rabbitmq-server \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*
