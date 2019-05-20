#!/bin/bash

set -Eeuo pipefail

docker_org="${1}"
tag="${2}"

build_args=''
for ba in $BUILD_ARGS; do
  build_args="${build_args} --build-arg ${ba}"
done

echo -e "#!/usr/bin/env bash\nset -Eeuo pipefail\nexec python${MAJOR_VERSION}.${MINOR_VERSION} \"\$@\"" > entrypoint.sh

image_tag=''
if [ "x${tag}" = "xlatest" ]; then
  image_tag="${MAJOR_VERSION}.${MINOR_VERSION}-${tag}"
else
  image_tag="${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}-${tag}"
fi
docker build ${build_args} -t ${docker_org}/python:${image_tag} .
docker build ${build_args} -t ${docker_org}/python${MAJOR_VERSION}:${image_tag} .