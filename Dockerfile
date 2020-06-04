#FROM mhart/alpine-node:7.10.1
FROM arm64v8/node:7.10.1-stretch

# File Author / Maintainer
MAINTAINER Husni

RUN apt-get -y update && \
	apt-get -y upgrade && \
	apt-get -y install build-essential python

RUN addgroup --system openhabcloud && \
	adduser --no-create-home --system --gecos openhabcloud openhabcloud
    
# Add proper timezone
RUN apt-get -y install tzdata && \
	cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
	echo "America/Los_Angeles" >  /etc/timezone

# Cleanup container
RUN rm -rf \
    /usr/share/man \
    /tmp/* /var/cache/apt/* \
    /root/.npm \
    /root/.node-gyp \
    /root/.gnupg \
    /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc \
    /usr/lib/node_modules/npm/html \
    /usr/lib/node_modules/npm/scripts

RUN mkdir -p /opt/openhabcloud/logs
RUN mkdir /data

COPY ./package.json /opt/openhabcloud/
RUN ln -s /opt/openhabcloud/package.json /data

WORKDIR /data
RUN npm install && npm rebuild bcrypt --build-from-source
ENV NODE_PATH /data/node_modules

ADD . /opt/openhabcloud

RUN rm -Rf /opt/openhabcloud/deployment
RUN rm -Rf /opt/openhabcloud/docs
RUN rm -Rf /opt/openhabcloud/tests
RUN rm /opt/openhabcloud/config-development.json
RUN rm /opt/openhabcloud/config-production.json

RUN chown openhabcloud: /opt/openhabcloud/logs

WORKDIR /opt/openhabcloud
USER openhabcloud
EXPOSE 3000
CMD ["node", "app.js"]
