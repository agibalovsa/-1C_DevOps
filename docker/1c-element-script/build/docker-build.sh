#!/bin/bash

# shellcheck disable=SC2034
BUILD_ARGS=(
"--build-arg" "OS_TAG=${OS_TAG}"
"--build-arg" "OC_SCRIPT_VERSION=${OC_SCRIPT_VERSION}"
)

TAG="${OC_SCRIPT_TAG}"
REL_PATH="../../"

# shellcheck disable=SC1091
source "${REL_PATH}/common_context/build/docker"

docker_build "${1}" "${2}"