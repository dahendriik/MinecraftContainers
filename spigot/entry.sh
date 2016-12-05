#!/bin/bash
sleep 5

C_RED=`tput setaf 1`
C_GREEN=`tput setaf 2`
C_RESET=`tput sgr0`

cd /home/container

# Determine what is being considered as the start file.
if [ -z "${SERVER_JARFILE}" ]; then
    SERVER_JARFILE="server.jar"
fi

# Download the correct version, or skip if it already exists.
if [ -f "/home/container/${SERVER_JARFILE}" ]; then
    echo "${C_GREEN}Found ${SERVER_JARFILE} in container, not downloading or building new jar.${C_RESET}"
else

    if [ -z "${DL_PATH}" ] || [ "${DL_PATH}" == "build" ]; then
        mkdir -p /home/container/.tmp-build
        cd /home/container/.tmp-build

        echo ":/home/container/.tmp-build$ curl -sS -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
        curl -sS -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

        if [ $? -ne 0 ]; then
            echo "${C_RED}PTDL_CONTAINER_ERR: There was an error while attempting to download BuildTools.${C_RESET}"
            exit 1
        fi

        echo ":/home/container/.tmp-build$ git config --global --unset core.autocrlf"
        git config --global --unset core.autocrlf

        echo ":/home/container/.tmp-build$ java -jar BuildTools.jar --rev ${DL_VERSION}"
        java -jar BuildTools.jar --rev ${DL_VERSION}

        if [ $? -ne 0 ]; then
            echo "${C_RED}PTDL_CONTAINER_ERR: There was an error while attempting to run BuildTools.${C_RESET}"
            exit 1
        fi

        cp /home/container/.tmp-build/spigot-*.jar /home/container/${SERVER_JARFILE}
        rm -r /home/container/.tmp-build

        cd /home/container
    else
        MODIFIED_DL_PATH=`eval echo $(echo ${DL_PATH} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
        echo "${C_GREEN}Downloading Spigot from remote source.${C_RESET}"
        curl -sSLo ${SERVER_JARFILE} ${MODIFIED_DL_PATH}

        if [ $? -ne 0 ]; then
            echo "${C_RED}PTDL_CONTAINER_ERR: There was an error while attempting to download from a remote location.${C_RESET}"
            exit 1
        fi
    fi
fi

cd /home/container
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
