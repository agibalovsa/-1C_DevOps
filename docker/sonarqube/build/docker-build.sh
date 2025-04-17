#!/bin/bash

# shellcheck source=/dev/null
source .arg

docker build \
  --build-arg "SONARQUBE_VERSION=${SONARQUBE_VERSION}" \
  --build-arg "RUSSIAN_PACK=${RUSSIAN_PACK}" \
  --build-arg "BRANCH_PLUGIN_VERSION=${BRANCH_PLUGIN_VERSION}" \
  --build-arg "BSL_PLUGIN_VERSION=${BSL_PLUGIN_VERSION}" \
  --build-arg "ROOT_CERTS=${ROOT_CERTS}" \
  -t "sonarqube/1c:${SONARQUBE_VERSION}-${BSL_PLUGIN_VERSION}" \
  .
