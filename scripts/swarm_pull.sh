#!/usr/bin/env bash

set -e

function print_help {
    echo "Usage: $0 <docker_image> <swarm_address>"
    echo
    echo "Will pull the specified image into all Swarm hosts"
    echo "Specify the full image name: [registry]/<repository>/<image name>:version"
    exit
}

if [ -z $1 -o -z $2 ]; then
	print_help
fi

IMAGE_NAME=$1
SWARM_ADDRESS=$2

docker -H ${SWARM_ADDRESS} pull ${IMAGE_NAME}

