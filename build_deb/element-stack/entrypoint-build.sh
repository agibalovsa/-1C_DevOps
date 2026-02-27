#!/bin/bash

libName="${1}"

cd "${libName}" || exit 1

./debuild.sh