#!/usr/bin/env bash

set -Eeo pipefail

curl -X POST --unix-socket "/var/run/docker.sock" "http://localhost/containers/${DOMAIN_NAME}/kill?signal=HUP"