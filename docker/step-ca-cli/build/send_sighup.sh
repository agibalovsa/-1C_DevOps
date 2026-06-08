#!/usr/bin/env bash

set -Eeo pipefail

USER_DOMAIN_ID=${USER_DOMAIN_ID:-"1001"}
GROUP_DOMAIN_ID=${GROUP_DOMAIN_ID:-"1001"}
STEP_CA_HOME="/root/.step"
CERT_PATH=${CERT_PATH:-"${STEP_CA_HOME}/certs"}

chown "${USER_DOMAIN_ID}:${GROUP_DOMAIN_ID}" "${CERT_PATH}/*"

curl -X POST --unix-socket "/var/run/docker.sock" "http://localhost/containers/${DOMAIN_NAME}/kill?signal=HUP"