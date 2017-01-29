FROM java:openjdk-8-jre-alpine

MAINTAINER parkervcp, <parker@parkervcp.com>

COPY ./entry.sh /entry.sh

RUN adduser -D -h /home/container container \
 && apk update \
 && apk add curl \
 && chmod +x /entry.sh

USER container

ENV HOME=/home/container USER=container

WORKDIR /home/container

CMD ["/bin/ash", "/entry.sh"] 
