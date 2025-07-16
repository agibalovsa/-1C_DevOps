#!/bin/bash

# shellcheck source=/dev/null
source .arg
source ../context/ext/.arg

docker build \
  -t "${SOURCE}postgrespro/1c:${POSTGRES_VER}" \
  .

if [ -n "${SOURCE}" ]; then
  docker push "${SOURCE}postgrespro/1c:${POSTGRES_VER}"
fi;