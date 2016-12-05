#!/bin/bash
sleep 5

C_RED=`tput setaf 1`
C_GREEN=`tput setaf 2`
C_RESET=`tput sgr0`

cd /home/container

# Determine the latest version, or set the version to download.
if [ -z "${VANILLA_VERSION}" ] || [ "${VANILLA_VERSION}" == "latest" ]; then
    DL_VERSION=`curl -s https://s3.amazonaws.com/Minecraft.Download/versions/versions.json | grep -o "[[:digit:]]\.[0-9]*\.[0-9]" | head -n 1`
else
    DL_VERSION=${VANILLA_VERSION}
fi

# Determine what is being considered as the start file.
if [ -z "${SERVER_JARFILE}" ]; then
    SERVER_JARFILE="server.jar"
fi

# Download the correct version, or skip if it already exists.
if [ -f "/home/container/${SERVER_JARFILE}" ]; then
    echo "${C_GREEN}Found ${SERVER_JARFILE} in container, not downloading a new jar.${C_RESET}"
else
    echo ":/home/container$ curl -sS https://s3.amazonaws.com/Minecraft.Download/versions/${DL_VERSION}/minecraft_server.${DL_VERSION}.jar -o ${SERVER_JARFILE}"
    curl -sS https://s3.amazonaws.com/Minecraft.Download/versions/${DL_VERSION}/minecraft_server.${DL_VERSION}.jar -o ${SERVER_JARFILE}

    if [ $? -ne 0 ]; then
        echo "${C_RED}PTDL_CONTAINER_ERR: There was an error while attempting to download a new jarfile for this server.${C_RESET}"
        exit 1
    fi
fi

# Output Current Java Version
java -version

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ java ${MODIFIED_STARTUP}"

# Run the Server
java ${MODIFIED_STARTUP}

if [ $? -ne 0 ]; then
    echo "${C_RED}PTDL_CONTAINER_ERR: There was an error while attempting to run the start command.${C_RESET}"
    exit 1
fi
