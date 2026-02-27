#!/bin/bash

docker run --rm -it \
  -v "${LIB_PATH}:/srv/deb" \
  "${BUILDER_TAG}" \
  "${LIB_NAME}"