#!/bin/bash

# shellcheck disable=SC2034
BUILD_ARGS=(
"--build-arg" "OS_TAG=${OS_TAG}"
"--build-arg" "STEP_CA_VERSION=${STEP_CA_VERSION}" \
)

TAG="${STEP_CA_TAG}"
REL_PATH="../../"

# shellcheck disable=SC1091
source "${REL_PATH}/common_context/build/docker"

docker_build "${1}" "${2}"