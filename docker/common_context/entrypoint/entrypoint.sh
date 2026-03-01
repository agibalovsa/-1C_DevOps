#!/usr/bin/env bash

set -Eeo pipefail

if [ "$1" == "sh" ]; then
    exec sh
elif [ "$1" == "bash" ] || [ "$1" == "" ]; then
    exec /bin/bash
elif [[ "$1" == *"="* ]]; then
    for param in "$@"; do
        key="${param%%=*}"
        value="${param#*=}"
        SH_EXEC=( "entrypoint.d/entrypoint_${key}.sh" "$value" )
        exec "${SH_EXEC[@]}" 
    done
else
    echo "Wrong parameter: $1" >&2
    exit 1
fi

exit 0