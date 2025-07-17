#!/usr/bin/env bash

set -Eeo pipefail

# esb

setup_esb_healthcheck() {

    if [ ! -f "/healthcheck.sh" ]; then
        echo "curl -f http://localhost:9090/maintenance/server/v1/heartbeat || exit 1" > /healthcheck.sh;
        chmod 766 /healthcheck.sh;
    fi;

}

setup_esb_exec() {

    if [ "$OC_ESB_TYPE" == "esbide" ]; then
        export OC_ESB_SERVICE=1c-enterprise-esb-with-ide
    else
        export OC_ESB_SERVICE=1c-enterprise-esb
    fi

    OC_ESB_EXEC="gosu usr1ce /opt/1C/1CE/components/${OC_ESB_SERVICE}-${OC_ESB_VERSION}-x86_64/bin/esb start --instance /var/opt/1C/1CE/instances/${OC_ESB_SERVICE}";

}

run_esb_exec() {

    if [ -f /var/opt/1C/1CE/instances/${OC_ESB_SERVICE}/daemon.pid ]; then
        rm /var/opt/1C/1CE/instances/${OC_ESB_SERVICE}/daemon.pid
    fi

    echo "Begining 1c-esb";
    exec ${OC_ESB_EXEC} 2>&1;

}

esb() {

    setup_esb_healthcheck

    setup_esb_exec
    run_esb_exec

}

if [ "$1" == "sh" ]; then
    exec sh
elif [ "$1" == "bash" ]; then
    exec /bin/bash
elif [ "$1" = "esb" ]; then
    esb
else
    exec /bin/bash
fi

exit 0