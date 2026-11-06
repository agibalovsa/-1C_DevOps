#!/usr/bin/env bash

set -Eeo pipefail

if [ "$1" == "sh" ]; then
    exec sh
elif [ "$1" == "bash" ] || [ "$1" == "" ]; then
    exec /bin/bash
elif [[ "$1" == *"="* ]]; then
    key="${1%%=*}"
    value="${1#*=}"
    SH_EXEC=( "/entrypoint.d/entrypoint_${key}.sh" "$value" )
    exec "${SH_EXEC[@]}" 
else
    echo "Wrong parameter: $1" >&2
    exit 1
fi

exit 0