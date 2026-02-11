#!/bin/bash

if [ ! -d "context/distr" ]; then
    mkdir "context/distr"
fi

docker build \
  --build-arg "REGISTRY=${REGISTRY}" \
  --build-arg "OS_TAG=${OS_TAG}" \
  --build-arg "OC_VERSION=${OC_VERSION}" \
  --build-arg "OC_MODE=${OC_MODE}" \
  --build-context context=context \
  --build-context common_context=../../../common_context/build \
  --build-context "context_arg=${CONTEXT_ARG}" \
  -t "${REGISTRY}${OC_TAG}" \
  .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${OC_TAG}"
fi