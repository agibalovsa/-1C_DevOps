#!/bin/bash

docker build \
    --build-arg "REGISTRY=${REGISTRY}" \
    --build-arg "OS_TAG=${OS_TAG}" \
    --build-arg "IM_VERSION=${IM_VERSION}" \
    --build-arg "AOM_VERSION=${AOM_VERSION}" \
    --build-arg "HEIF_VERSION=${HEIF_VERSION}" \
    --build-arg "JXL_VERSION=${JXL_VERSION}" \
    --build-arg "IMEI_VERSION=${IMEI_VERSION}" \
    --build-context context=context \
    --build-context common_context=../../common_context/build \
    --build-context "context_arg=${CONTEXT_ARG}" \
    -t "${REGISTRY}${IM_TAG}" \
    .

if [ "${1}" = "push" ] && [ -n "${REGISTRY}" ]; then
    docker push "${REGISTRY}${IM_TAG}"
fi