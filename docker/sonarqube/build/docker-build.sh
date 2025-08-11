#!/bin/bash

docker build \
    --build-arg "SONAR_REPO=${SONAR_REPO}" \
    --build-arg "SONAR_VERSION=${SONAR_VERSION}" \
    --build-arg "RUSSIAN_PACK_VERSION=${RUSSIAN_PACK_VERSION}" \
    --build-arg "BRANCH_PLUGIN_VERSION=${BRANCH_PLUGIN_VERSION}" \
    --build-arg "BSL_PLUGIN_VERSION=${BSL_PLUGIN_VERSION}" \
    --build-context context=context \
    --build-context common_context=../../common_context/build \
    --build-context "context_arg=${CONTEXT_ARG}" \
    -t "${REGISTRY}${SONAR_TAG}" \
    .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${SONAR_TAG}"
fi