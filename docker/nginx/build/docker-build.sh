#!/bin/bash

docker build \
  --build-arg "NGINX_REPO=${NGINX_REPO}" \
  --build-arg "NGINX_VERSION=${NGINX_VERSION}" \
  --build-context context=context \
  --build-context "context_arg=${CONTEXT_ARG}" \
  -t "${REGISTRY}${NGINX_TAG}" \
  .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${NGINX_TAG}"
fi