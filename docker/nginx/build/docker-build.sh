#!/bin/bash

docker build \
  -t "${REGISTRY}${NGINX_TAG}" \
  .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${NGINX_TAG}"
fi