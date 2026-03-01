#!/usr/bin/env bash

set -Eeo pipefail

# element

setup_element_healthcheck()
{

    if [ ! -f "/healthcheck.sh" ]; then
        echo "curl -f http://localhost:9090/maintenance/server/v1/heartbeat || exit 1" > /healthcheck.sh;
        chmod 766 /healthcheck.sh;
    fi;

}

setup_element_config()
{

    if [ "$OC_ELEMENT_TYPE" == "element-ide" ]; then
        export OC_ELEMENT_SERVICE=1c-enterprise-element-server-with-ide
        export OC_ELEMENT_SERVICE_BIN=element-server
    elif [ "$OC_ELEMENT_TYPE" == "esb-ide" ]; then
        export OC_ELEMENT_SERVICE=1c-enterprise-esb-with-ide
        export OC_ELEMENT_SERVICE_BIN=esb
    else
        export OC_ELEMENT_SERVICE=1c-enterprise-esb
        export OC_ELEMENT_SERVICE_BIN=esb
    fi

    ideManagerPath="/var/opt/1C/1CE/instances/${OC_ELEMENT_SERVICE}/config/ide-manager.yml"
    if grep -q "0.0.0.0" "${ideManagerPath}" 2>/dev/null; then
        sed -i -e "s/0.0.0.0/127.0.0.1/g" "${ideManagerPath}"
        echo "Set ide-manager.yml to 127.0.0.1"
    fi
    serverPath="/var/opt/1C/1CE/instances/${OC_ELEMENT_SERVICE}/config/server.yml"
    if grep -q "127.0.0.1" "${serverPath}" 2>/dev/null; then
        sed -i -e "s/127.0.0.1/0.0.0.0/g" "${serverPath}"
        echo "Set server.yml to 0.0.0.0"
    fi

}

setup_element_exec()
{
    OC_ELEMENT_EXEC=( gosu usr1ce "opt/1C/1CE/components/${OC_ELEMENT_SERVICE}-${OC_ELEMENT_VERSION}-x86_64/bin/${OC_ELEMENT_SERVICE_BIN}" start )
    OC_ELEMENT_EXEC+=( --procname "${OC_ELEMENT_VERSION}-launcher" )
    OC_ELEMENT_EXEC+=( --servicename "${OC_ELEMENT_VERSION}" )
    OC_ELEMENT_EXEC+=( --instance "/var/opt/1C/1CE/instances/${OC_ELEMENT_SERVICE}" )
}

run_element_exec()
{

    if [ -f /var/opt/1C/1CE/instances/${OC_ELEMENT_SERVICE}/daemon.pid ]; then
        rm /var/opt/1C/1CE/instances/${OC_ELEMENT_SERVICE}/daemon.pid
    fi

    echo "Beginning 1c-element";
    exec "${OC_ELEMENT_EXEC[@]}" 2>&1;

}

element()
{

    setup_element_healthcheck

    setup_element_config
    setup_element_exec
    run_element_exec

}

if [ "$1" = "element" ] || [ "$1" = "esb" ] ; then
    element
else
    echo "Wrong parameter: $1" >&2
    exit 1
fi

exit 0
