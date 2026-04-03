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

    if [ "${OC_ELEMENT_TYPE}" == "element-ide" ]; then
        export OC_ELEMENT_SERVICE=1c-enterprise-element-server-with-ide
        export OC_ELEMENT_SERVICE_BIN=element-server
    elif [ "${OC_ELEMENT_TYPE}" == "esb-ide" ]; then
        export OC_ELEMENT_SERVICE=1c-enterprise-esb-with-ide
        export OC_ELEMENT_SERVICE_BIN=esb
    else
        export OC_ELEMENT_SERVICE=1c-enterprise-esb
        export OC_ELEMENT_SERVICE_BIN=esb
    fi

    # Для подключения к 1С:Элементу с IDE как к внешнему сервису подходит такая комбинация настроек
    configPath="/var/opt/1C/1CE/instances/${OC_ELEMENT_SERVICE}/config"
    ideManagerPath="${configPath}/ide-manager.yml"
    serverPath="${configPath}/server.yml"
    integrationBusPath="${configPath}/integrationBus.yml"
    debugPath="${configPath}/debug.yml"
    address0="address: 0.0.0.0"
    address127="address: 127.0.0.1"
    if grep -qwF "${address0}" "${ideManagerPath}" 2>/dev/null; then
        sed -i -e "s|${address0}|${address127}|g" "${ideManagerPath}"
        echo "Set ip ide-manager.yml to ${address127}"
    fi;
    if grep -qwF "${address127}" "${serverPath}" 2>/dev/null; then
        sed -i -e "s|${address127}|${address0}|g" "${serverPath}"
        echo "Set ip server.yml to ${address0}"
    fi;
    if ! grep -qwF "${address0}:${OC_ELEMENT_IDE_SERVER_PORT}" "${serverPath}" 2>/dev/null; then
        sed -i -E "s|(${address0}:)[0-9]+|\1${OC_ELEMENT_IDE_SERVER_PORT}|" "${serverPath}"
        echo "Set port server.yml to ${OC_ELEMENT_IDE_SERVER_PORT}"
    fi;
    if ! grep -qw "port: ${OC_ELEMENT_IDE_BUS_PORT}" "${integrationBusPath}" 2>/dev/null; then
        sed -i -E "s/(port: )[0-9]+/\1${OC_ELEMENT_IDE_BUS_PORT}/" "${integrationBusPath}"
        echo "Set port integrationBus.yml to ${OC_ELEMENT_IDE_BUS_PORT}"
    fi;
    if ! grep -qw "port: ${OC_ELEMENT_IDE_DEBUG_PORT}" "${debugPath}" 2>/dev/null; then
        sed -i -E "s/(port: )[0-9]+/\1${OC_ELEMENT_IDE_DEBUG_PORT}/" "${debugPath}"
        echo "Set port debug.yml to ${OC_ELEMENT_IDE_DEBUG_PORT}"
    fi;

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

    echo "Beginning ${OC_ELEMENT_TYPE} service";
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
