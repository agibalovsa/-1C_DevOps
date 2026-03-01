#!/bin/bash

# shellcheck disable=SC2034
BUILD_ARGS=(
"--build-arg" "OS_EXT_TAG=${OS_EXT_TAG}"
)

TAG="${OS_TAG}"
REL_PATH="../../../"

# shellcheck disable=SC1091
source "${REL_PATH}/common_context/build/docker"

docker_build "${1}" "${2}"