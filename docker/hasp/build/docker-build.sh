#!/bin/bash

docker build \
    --build-arg "REGISTRY=${REGISTRY}" \
    --build-arg "OS_TAG=${OS_TAG}" \
    --build-arg "HASP_VERSION=${HASP_VERSION}" \
    --build-context context=context \
    --build-context common_context=../../common_context/build \
    --build-context "context_arg=${CONTEXT_ARG}" \
    -t "${REGISTRY}${HASP_TAG}" \
    .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${HASP_TAG}"
fi