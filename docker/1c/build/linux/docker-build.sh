#!/bin/bash

# shellcheck disable=SC2034
BUILD_ARGS=(
"--build-arg" "OS_TAG=${OS_TAG}"
"--build-arg" "OC_VERSION=${OC_VERSION}" \
"--build-arg" "OC_MODE=${OC_MODE}" \
)

BUILD_CNTXT=(
"--build-context" "scripts=../../../../scripts"
)

BUILD_SCRTS=(
"--secret" "id=its_secret,src=${CONTEXT_SECRET}"
)

TAG="${OC_TAG}"
REL_PATH="../../../"

# shellcheck disable=SC1091
source "${REL_PATH}/common_context/build/docker"

docker_build "${1}" "${2}"