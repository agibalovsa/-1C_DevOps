#!/bin/bash

# shellcheck disable=SC2034
BUILD_ARGS=(
"--build-arg" "OS_BUILD_TAG=${OS_BUILD_TAG}"
"--build-arg" "OS_TAG=${OS_TAG}"
"--build-arg" "VANESSA_VERSION=${VANESSA_VERSION}"
)

TAG="${VANESSA_TAG}"
REL_PATH="../../"

# shellcheck disable=SC1091
source "${REL_PATH}/common_context/build/docker"

docker_build "${1}" "${2}"