#!/bin/bash

docker pull "${OS_EXT_TAG}"

docker build \
  --build-arg "OS_EXT_TAG=${OS_EXT_TAG}" \
  --build-context common_context=../../../common_context/build \
  --build-context context=context \
  -t "${REGISTRY}${OS_TAG}" \
  .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${OS_TAG}"
fi