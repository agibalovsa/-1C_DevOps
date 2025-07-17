#!/bin/bash

docker build \
    --build-arg "REGISTRY=${REGISTRY}" \
    --build-arg "JDK_TAG=${JDK_TAG}" \
    --build-arg "OC_ANS_VERSION=${OC_ANS_VERSION}" \
    --build-context common_context=../../common_context/build \
    --build-context "context_arg=${CONTEXT_ARG}" \
    -t "${REGISTRY}${OC_ANS_TAG}" \
    .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${OC_ANS_TAG}"
fi