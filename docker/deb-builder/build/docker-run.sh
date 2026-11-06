#!/bin/bash

BUILDER_TAG="os/builder:deb"
LIB_PATH=""
LIB_NAME=""

docker run --rm -it \
  -v "${LIB_PATH}:/srv/deb" \
  "${BUILDER_TAG}" \
  "${LIB_NAME}"