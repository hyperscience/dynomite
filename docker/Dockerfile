##########################################################################
# Dockerfile to build Dynomite container images with Redis as the backend
# Based on Ubuntu
##########################################################################
# Copyright 2015 Netflix, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##########################################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Ioannis Papapanagiotou - dynomite@netflix.com

# Update the repository sources list and Install package Build Essential
RUN apt-get update && \
	export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y \
	autoconf \
	build-essential \
	dh-autoreconf \
	git \
	libssl-dev \
	libtool \
	software-properties-common \
	redis-server \
	tcl8.5

# Clone the Dynomite Git
RUN git clone https://github.com/Netflix/dynomite.git
RUN echo 'Git repo has been cloned in your Docker VM'

# Move to working directory
WORKDIR dynomite/

# Autoreconf
RUN autoreconf -fvi \
	&& ./configure --enable-debug=log \
	&& CFLAGS="-ggdb3 -O0" ./configure --enable-debug=full \
	&& make \
	&& make install

##################### INSTALLATION ENDS #####################

# Expose the peer port
RUN echo 'Exposing peer port 8101'
EXPOSE 8101

# Expose the underlying Redis port
RUN echo 'Exposing Redis port 22122'
EXPOSE 22122

# Expose the stats/admin port
RUN echo 'Exposing stats/admin port 22222'
EXPOSE 22222

# Default port to acccess Dynomite
RUN echo 'Exposing client port for Dynomite 8102'
EXPOSE 8102


# Setting overcommit for Redis to be able to do BGSAVE/BGREWRITEAOF
# TODO: based on redis log desipte this RUN the effective value is 0
RUN sysctl vm.overcommit_memory=1

ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /tini
RUN chmod +x /tini

RUN echo 'copy files'
COPY scripts/startup.sh /dynomite/startup.sh
COPY configs/redis.conf /etc/redis/redis.conf
RUN echo 'done copying files'

ENTRYPOINT ["/tini", "-s", "--", "/dynomite/startup.sh"]
