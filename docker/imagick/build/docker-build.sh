#!/bin/bash

# shellcheck disable=SC2034
BUILD_ARGS=(
    "--build-arg" "OS_TAG=${OS_TAG}"
    "--build-arg" "IM_VERSION=${IM_VERSION}" \
    "--build-arg" "AOM_VERSION=${AOM_VERSION}" \
    "--build-arg" "HEIF_VERSION=${HEIF_VERSION}" \
    "--build-arg" "JXL_VERSION=${JXL_VERSION}" \
    "--build-arg" "IMEI_VERSION=${IMEI_VERSION}" \
)

if [ "${1}" = "deb" ]; then
    BUILD_ARGS+=(
        "--target" "deb" \
        "--output" "deb" \
    )
else
    TAG="${IM_TAG}"
fi

REL_PATH="../../"

# shellcheck disable=SC1091
source "${REL_PATH}/common_context/build/docker"

docker_build "${1}" "${2}"