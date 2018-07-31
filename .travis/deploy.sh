#!/bin/bash

set -Eeuo pipefail

docker_org="${1}"
tag="${2}"

for params in $(< versions.txt); do
  arr_param=(${params//,/ })
  for build_arg in ${arr_param[@]}; do
    eval "export ${build_arg}"
  done

  image_name=''
  if [ "x${tag}" = "xlatest" ]; then
    image_name="${docker_org}/python:${MAJOR_VERSION}.${MINOR_VERSION}-${tag}"
  else
    image_name="${docker_org}/python:${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}-${tag}"
  fi

  docker push ${image_name}
done