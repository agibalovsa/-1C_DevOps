#!/bin/bash

docker build \
    --build-arg "REGISTRY=${REGISTRY}" \
    --build-arg "JDK_TAG=${JDK_TAG}" \
    --build-arg "OC_ESB_TYPE=${OC_ESB_TYPE}" \
    --build-arg "OC_ESB_VERSION=${OC_ESB_VERSION}" \
    --build-context common_context=../../common_context/build \
    --build-context "context_arg=${CONTEXT_ARG}" \
    -t "${REGISTRY}${OC_ESB_TAG}" \
    .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${OC_ESB_TAG}"
fi