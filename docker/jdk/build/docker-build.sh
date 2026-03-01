#!/bin/bash

# shellcheck disable=SC2034
BUILD_ARGS=(
"--build-arg" "OS_TAG=${OS_TAG}"
"--build-arg" "JDK_KIT=${JDK_KIT}"
"--build-arg" "JDK_VERSION=${JDK_VERSION}"
"--build-arg" "JDK_PROD=${JDK_PROD}"
"--build-arg" "JDK_PATH=${JDK_PATH}"
)

TAG="${JDK_TAG}"
REL_PATH="../../"

# shellcheck disable=SC1091
source "${REL_PATH}/common_context/build/docker"

docker_build "${1}" "${2}"