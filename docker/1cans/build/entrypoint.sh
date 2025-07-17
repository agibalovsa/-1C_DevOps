#!/usr/bin/env bash

set -Eeo pipefail

# ans

setup_ans_healthcheck() {

    if [ ! -f "/healthcheck.sh" ]; then
        echo "curl -f http://localhost:8181/maintenance/server/v1/heartbeat || exit" >> ./healthcheck.sh
        chmod 766 ./healthcheck.sh;
    fi;

}

setup_ans_exec() {

    OC_ANS_EXEC="gosu usrans /var/opt/1cans/executable/start.sh"

}

run_ans_exec() {

    if [ -f /var/opt/1cans/executable/_data/daemon.pid ]; then
      rm /var/opt/1cans/executable/_data/daemon.pid
    fi

    echo "Begining 1c-ans";
    exec ${OC_ANS_EXEC} 2>&1;

}

ans() {

    setup_ans_healthcheck

    setup_ans_exec
    run_ans_exec

}

if [ "$1" == "sh" ]; then
    exec sh
elif [ "$1" == "bash" ]; then
    exec /bin/bash
elif [ "$1" = "ans" ]; then
    ans
else
    exec /bin/bash
fi

exit 0