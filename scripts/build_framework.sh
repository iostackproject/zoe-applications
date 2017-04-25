#!/usr/bin/env bash

SCRIPT_DIR=$(readlink -f $(dirname ${0}))
FRAMEWORKS_DIR="${SCRIPT_DIR}/../frameworks"

set -e

REGISTRY=''
VERSION=''
PUSH=0
SWARM_ADDRESS=''

function print_help {
    echo "Usage: $0 [-r registry] [-v version] [-p] [-s swarm_address] <framework> <repository>"
    echo
    echo "Will build Docker images names [registry]/<repository>/<image name>:version"
    echo "If -p is specified, docker push will be called at the end of the build"
    echo "If a Swarm address is specified with -s, Swarm pull will be called at the end of the build"
    exit
}

while getopts ":hr:v:s:p" opt; do
    case ${opt} in
        \?|h)
          print_help
          ;;
        r)
          REGISTRY=${OPTARG}/
          ;;
        v)
          VERSION=:${OPTARG}
          ;;
        p)
          PUSH=1
          ;;
        s)
          SWARM_ADDRESS=${OPTARG}
          ;;
    esac
done
shift $((OPTIND-1))

if [ -z ${1} -o -z ${2} ]; then
    print_help
fi

FRAMEWORK=${1}
REPOSITORY=${2}

FIND_OUTPUT=$(find "${FRAMEWORKS_DIR}/${FRAMEWORK}/images" -mindepth 1 -maxdepth 1 -type d -printf '%f ' 2> /dev/null)
if [ $? -eq 1 ]; then
   echo "The name of the framework (${FRAMEWORK}) is not available."
   echo "Please choose between the following: "$(find ${FRAMEWORKS_DIR} -mindepth 1 -maxdepth 1 -type d -printf '%f ')
fi

for IMAGE in ${FIND_OUTPUT}; do
  pushd "${FRAMEWORKS_DIR}/${FRAMEWORK}/images/${IMAGE}" > /dev/null
  echo "# Building image ${IMAGE}"
  FULL_IMAGE_NAME="${REGISTRY}${REPOSITORY}/${IMAGE}${VERSION}"
  docker build -t ${FULL_IMAGE_NAME} .
  if [ ${PUSH} = 1 ]; then
    echo "# Pushing image ${FULL_IMAGE_NAME} to Docker"
    docker push ${FULL_IMAGE_NAME}
  fi
  if [ ! -z ${SWARM_ADDRESS} ]; then
    echo "# Pulling image ${FULL_IMAGE_NAME} on Swarm (${SWARM_ADDRESS})"
    docker -H ${SWARM_ADDRESS} pull ${FULL_IMAGE_NAME}
  fi
  popd > /dev/null
done
