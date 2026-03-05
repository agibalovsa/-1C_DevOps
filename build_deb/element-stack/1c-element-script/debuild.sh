#!/bin/bash

set -eux;

version=$(dpkg-parsechangelog -S Version)

read -rsp "Get API Key (https://developer.1c.ru/applications/): " apiKey
(cd "../distr/" && rm -rf ./* && curl -H "X-Developer-1c-Api:${apiKey}" -OJ "https://developer.1c.ru/applications/Console/api/v1/download/elementscript/${version}/linux")

# shellcheck disable=SC1091
. ../build_lib

start_debuild

rm ../distr/*
