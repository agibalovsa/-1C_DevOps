#!/bin/bash

docker build \
    --build-arg "REGISTRY=${REGISTRY}" \
    --build-arg "OS_TAG=${OS_TAG}" \
    --build-arg "JDK_KIT=${JDK_KIT}" \
    --build-arg "JDK_VERSION=${JDK_VERSION}" \
    --build-arg "JDK_PROD=${JDK_PROD}" \
    --build-arg "JDK_PATH=${JDK_PATH}" \
    --build-context context=context \
    --build-context common_context=../../common_context/build \
    --build-context "context_arg=${CONTEXT_ARG}" \
    -t "${REGISTRY}${JDK_TAG}" \
    .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${JDK_TAG}"
fi