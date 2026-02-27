#!/bin/bash

if [ -d "/srv/deb" ]; then
    cd /srv/deb || exit 1
    chmod +x ./entrypoint-build.sh
    ./entrypoint-build.sh "${1}"
else
    bash
fi