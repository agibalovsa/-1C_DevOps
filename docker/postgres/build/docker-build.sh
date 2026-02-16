#!/bin/bash

# shellcheck disable=SC2034
BUILD_ARGS=(
"--build-arg" "OS_TAG=${OS_TAG}"
"--build-arg" "PG_MANUFACTURER=${PG_MANUFACTURER}"
"--build-arg" "PG_MAJOR_VERSION=${PG_MAJOR_VERSION}"
"--build-arg" "PG_VERSION=${PG_VERSION}"
"--build-arg" "PG_PATH=${PG_PATH}"
"--build-arg" "PG_BIN_PATH=${PG_BIN_PATH}"
"--build-arg" "PG_SHARE_PATH=${PG_SHARE_PATH}"
"--build-arg" "PG_RU=${PG_RU}"
)

TAG="${PG_TAG}"
REL_PATH="../../"

# shellcheck disable=SC1091
source "${REL_PATH}/common_context/build/docker"

docker-build "${1}" "${2}"