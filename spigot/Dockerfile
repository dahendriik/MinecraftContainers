# +-----------------------------------+
# | Official Pterodactyl Docker Image |
# |         Minecraft: Spigot         |
# +-----------------------------------+
# |       https://pterodactyl.io      |
# +-----------------------------------+
FROM openjdk:8-jre

MAINTAINER Pterodactyl Software, <support@pterodactyl.io>

RUN apt update \
    && apt upgrade -y \
    && apt install -y --no-install-recommends curl git tar \
    && adduser --disabled-password --home /home/container --gecos "" container \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER container
ENV HOME=/home/container USER=container

WORKDIR /home/container

COPY entry.sh /entry.sh

CMD ["/bin/bash", "/entry.sh"]
