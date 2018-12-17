#!/bin/bash

set -Eeuo pipefail

docker_org="${1}"
tag="${2}"

image_tag=''
if [ "x${tag}" = "xlatest" ]; then
  image_tag="${MAJOR_VERSION}.${MINOR_VERSION}-${tag}"
else
  image_tag="${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}-${tag}"
fi

docker push ${docker_org}/python:${image_tag}
docker push ${docker_org}/python${MAJOR_VERSION}:${image_tag}