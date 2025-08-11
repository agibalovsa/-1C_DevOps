#!/bin/bash

docker build \
    --build-arg "REGISTRY=${REGISTRY}" \
    --build-arg "OS_TAG=${OS_TAG}" \
    --build-arg "PG_MAJOR_VERSION=${PG_MAJOR_VERSION}" \
    --build-arg "PG_VERSION=${PG_VERSION}" \
    --build-arg "PG_PATH=${PG_PATH}" \
    --build-arg "PG_BIN_PATH=${PG_BIN_PATH}" \
    --build-arg "PG_SHARE_PATH=${PG_SHARE_PATH}" \
    --build-context context=context \
    --build-context "context_arg=${CONTEXT_ARG}" \
    -t "${REGISTRY}${PG_TAG}" \
    .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${PG_TAG}"
fi