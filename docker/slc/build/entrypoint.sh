#!/usr/bin/env bash

set -Eeo pipefail

# slc

setup_slc_healthcheck() {

    if [ ! -f "/healthcheck.sh" ]; then
        echo "curl -f localhost:9099/systeminfo || exit 1" > /healthcheck.sh;
        chmod 766 /healthcheck.sh;
    fi;

}

setup_slc_exec() {

    SLC_EXEC="/opt/1C/licence/3.0/licenceserver -r";

}

run_slc_exec() {

    echo "Begining slc";
    exec ${SLC_EXEC} 2>&1;

}

slc() {

    setup_slc_healthcheck

    setup_slc_exec
    run_slc_exec

}

if [ "$1" == "sh" ]; then
    exec sh
elif [ "$1" == "bash" ]; then
    exec /bin/bash
elif [ "$1" = "slc" ]; then
    slc
else
    exec /bin/bash
fi

exit 0