#!/bin/bash

docker build \
  --build-arg "REGISTRY=${REGISTRY}" \
  --build-arg "OS_TAG=${OS_TAG}" \
  --build-context context=context \
  -t "${REGISTRY}${GITLAB_MR_TAG}" \
  .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${GITLAB_MR_TAG}"
fi