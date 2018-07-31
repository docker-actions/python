#!/bin/bash

set -Eeuo pipefail

docker_org="${1}"
tag="${2}"

for params in $(< versions.txt); do
  arr_param=(${params//,/ })
  build_args=''
  for build_arg in ${arr_param[@]}; do
    build_args="${build_args} --build-arg ${build_arg}"
    eval "export ${build_arg}"
  done

  echo -e "#!/usr/bin/env bash\nset -Eeuo pipefail\nexec python${MAJOR_VERSION}.${MINOR_VERSION} \"\$@\"" > entrypoint.sh

  image_name=''
  if [ "x${tag}" = "xlatest" ]; then
    image_name="${docker_org}/python:${MAJOR_VERSION}.${MINOR_VERSION}-${tag}"
  else
    image_name="${docker_org}/python:${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}-${tag}"
  fi
  docker build ${build_args} -t ${image_name} .
done