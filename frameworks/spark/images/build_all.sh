#!/usr/bin/env bash

set -e

REGISTRY=''
VERSION=''
PUSH=0

function print_help {
    echo "Usage: $0 [-r registry] [-v version] [-p] <repository>"
    echo
    echo "Will build Docker images names [registry]/<repository>/<image name>:version"
    echo "If -p is specified, docker push will be called at the end of the build"
    exit
}

while getopts ":hr:v:p" opt; do
    case ${opt} in
        \?|h)
          print_help
          ;;
        r)
          REGISTRY=$OPTARG/
          ;;
        v)
          VERSION=:$OPTARG
          ;;
        p)
          PUSH=1
          ;;
    esac
done
shift $((OPTIND-1))

if [ -z $1 ]; then
    print_help
fi

REPOSITORY=$1

for d in $(ls -d */); do
  image_name=${d%%/}
  pushd ${d}
  docker build -t ${REGISTRY}${REPOSITORY}/${image_name}${VERSION} .
  if [ ${PUSH} = 1 ]; then
    docker push ${REGISTRY}${REPOSITORY}/${image_name}${VERSION}
  fi
  popd
done
