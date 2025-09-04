#!/bin/bash

docker build --progress=plain \
    --build-arg "REGISTRY=${REGISTRY}" \
    --build-arg "OS_TAG=${OS_TAG}" \
    --build-arg "OC_EXECUTOR_VERSION=${OC_EXECUTOR_VERSION}" \
    --build-context common_context=../../common_context/build \
    --build-context context=context \
    --build-context "context_arg=${CONTEXT_ARG}" \
    -t "${REGISTRY}${OC_EXECUTOR_TAG}" \
    .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${OC_EXECUTOR_TAG}"
fi