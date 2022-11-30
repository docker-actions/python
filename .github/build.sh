#!/bin/bash

set -Eeuo pipefail

docker_org="${1}"
version="${2}"
tag="${3:-latest}"
push="${4:-false}"

BUILD_ARGS="MAJOR_VERSION MINOR_VERSION PATCH_VERSION REQUIRED_PACKAGES"
MAJOR_VERSION=${version%?????}
MINOR_VERSION=$(echo $VERSION |cut -d '.' -f 2)
PATCH_VERSION=$(echo $VERSION |cut -d '.' -f 3)
REQUIRED_PACKAGES="python${MINOR_VERSION}-minimal libpython${MAJOR_VERSION}.${MINOR_VERSION}-minimal libpython${MAJOR_VERSION}-stdlib"
if [ "${MAJOR_VERSION}" == "3" ]; then
  REQUIRED_PACKAGES="${REQUIRED_PACKAGES} python${MAJOR_VERSION}-lib2to3"
fi

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
docker buildx build ${build_args} \
  --output "type=image,push=${push}" \
  --cache-from "type=local,src=/tmp/.buildx-cache" \
  --cache-to "type=local,dest=/tmp/.buildx-cache" \
  --tag ${docker_org}/python:${image_tag} \
  --tag ${docker_org}/python${MAJOR_VERSION}:${image_tag} \
  --platform linux/amd64,linux/arm64 .