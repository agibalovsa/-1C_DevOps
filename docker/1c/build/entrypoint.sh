#!/usr/bin/env bash

set -Eeo pipefail

# common

setup_init() {

    if [ -f logcfg.xml ]; then
        mv logcfg.xml /opt/1cv8/conf/logcfg.xml;
    fi;

    if [ -f /config_ibsrv.yml ]; then
        mkdir -p "$(dirname "${OC_IBSRV_CONFIG_PATH}")";
        mv /config_ibsrv.yml "${OC_IBSRV_CONFIG_PATH}";
    fi;

    if [ -f init.sh ]; then
        chmod 766 ./init.sh;
        ./init.sh;
        rm ./init.sh;
    fi;

}

# server

setup_ragent_healthcheck() {

    if [ ! -f "/healthcheck.sh" ]; then
        echo "gosu usr1cv8 rac cluster list localhost:${RAS_PORT:-$DEFAULT_RAS_PORT}" > /healthcheck.sh
        chmod 766 /healthcheck.sh
    fi;

}

setup_ragent_defaults() {

    OC_SRVINFO=${OC_SRVINFO:-"/home/usr1cv8/.1cv8"}
    OC_RAGENT_PORT=${OC_RAGENT_PORT:-"1540"}
    OC_RMNGR_PORT=${OC_RMNGR_PORT:-"1541"}
    OC_RAS_PORT=${OC_RAS_PORT:-"1545"}
    OC_DEBAGER_PORT=${OC_DEBAGER_PORT:-"1549"}
    OC_RPHOST_PORT=${OC_RPHOST_PORT:-"1560:1591"}
    OC_SECLEVEL=${OC_SECLEVEL:-"0"}
    OC_PING_PERIOD=${OC_PING_PERIOD:-"1000"}
    OC_PING_TIMEOUT=${OC_PING_TIMEOUT:-"5000"}
    OC_DEBUG_TYPE=${OC_DEBUG_TYPE:-"-tcp"}

}

setup_ragent_exec() {

    RAGENT_EXEC="gosu usr1cv8 ragent"
    RAGENT_EXEC+=" /regport ${OC_RMNGR_PORT}"
    RAGENT_EXEC+=" /range ${OC_RPHOST_PORT}"
    RAGENT_EXEC+=" /seclev ${OC_SECLEVEL}"
    RAGENT_EXEC+=" /d ${OC_SRVINFO}"
    RAGENT_EXEC+=" /pingPeriod ${OC_PING_PERIOD}"
    RAGENT_EXEC+=" /pingTimeout ${OC_PING_TIMEOUT}"
    if [ -n "$DEBUG" ]; then RAGENT_EXEC+=" /debug ${OC_DEBUG_TYPE}"; fi
    if [ -n "$DEBUGSERVERADDR" ]; then RAGENT_EXEC+=" /debugServerAddr $DEBUGSERVERADDR"; fi
    if [ -n "$DEBUG" ]; then RAGENT_EXEC+=" /debugServerPort ${OC_DEBAGER_PORT}"; fi
    if [ -n "$DEBUGSERVERPWD" ]; then RAGENT_EXEC+=" /debugServerPwd $DEBUGSERVERPWD"; fi

}

run_ragent_exec() {

    echo "Begining RAgent"
    echo "${RAGENT_EXEC}"
    exec ${RAGENT_EXEC} 2>&1

}

setup_ras_defaults() {

    OC_RAGENT_PORT=${OC_RAGENT_PORT:-"1540"}

}

setup_ras_exec() {

    RAS_EXEC="gosu usr1cv8 ras cluster --daemon"
    RAS_EXEC+=" --port ${OC_RAS_PORT}"
    RAS_EXEC+=" localhost:${OC_RAGENT_PORT}"

}

run_ras_exec_background() {

    echo "Begining Ras in background"
    echo "${RAS_EXEC}"
    ${RAS_EXEC} 2>&1 &

}

server() {

    setup_ragent_healthcheck

    setup_ragent_defaults
    setup_ragent_exec
    setup_ras_defaults
    setup_ras_exec

    setup_init

    run_ras_exec_background
    run_ragent_exec

}

# ibsrv

setup_ibsrv_healthcheck() {

    if [ ! -f "/healthcheck.sh" ]; then
        echo "curl http://localhost:${OC_IBSRV_HTTP_PORT}${OC_IBSRV_HTTP_BASE_NAME}" > /healthcheck.sh
        chmod 766 /healthcheck.sh
    fi;

}

setup_ibsrv_defaults() {

    OC_IBSRV_PORT=${OC_IBSRV_PORT:-"1541"}
    OC_IBSRV_RANGE_PORT=${OC_IBSRV_RANGE_PORT:-"1560:1591"}
    OC_IBSRV_SECLEVEL=${OC_IBSRV_SECLEVEL:-"0"}

    OC_IBSRV_HTTP_ADRESS=${OC_IBSRV_HTTP_ADRESS:-"any"}
    OC_IBSRV_HTTP_PORT=${OC_IBSRV_HTTP_PORT:-"8314"}
    OC_IBSRV_HTTP_BASE_NAME=${OC_IBSRV_HTTP_BASE_NAME:-"/ibsrv"}

    OC_IBSRV_BASE_NAME=${OC_IBSRV_BASE_NAME:-"ibsrv"}

    OC_IBSRV_CONFIG_PATH=${OC_IBSRV_CONFIG_PATH:-"/srv/1c/ibsrv/config_ibsrv.yml"}
    OC_IBSRV_FILE_BASE_PATH="/srv/1c/ibsrv/${OC_IBSRV_BASE_NAME}";

    OC_IBSRV_DBMS_KIND=${OC_IBSRV_DBMS_KIND:-} # MSSQLServer|PostrgeSQL|IBMDB2|OracleDatabase
    OC_IBSRV_DBMS_ADRESS=${OC_IBSRV_DBMS_ADRESS:-"localhost"}
    OC_IBSRV_DBMS_NAME=${OC_IBSRV_DBMS_NAME:-"ibsrv"}
    OC_IBSRV_DBMS_LOGIN=${OC_IBSRV_DBMS_LOGIN:-"ibsrv"}
    OC_IBSRV_DBMS_PASSWORD=${OC_IBSRV_DBMS_PASSWORD:-"ibsrv"}

    OC_IBSRV_DEBUG=${OC_IBSRV_DEBUG:-} # tcp|http|server
    OC_IBSRV_DEBUG_ADDRESS=${OC_IBSRV_DEBUG_ADDRESS:-"any"}
    OC_IBSRV_DEBUG_PORT=${OC_IBSRV_DEBUG_PORT:-"1550"}
    OC_IBSRV_DEBUG_PASSWORD=${OC_IBSRV_DEBUG_PASSWORD:-}
    OC_IBSRV_DEBUG_URL=${OC_IBSRV_DEBUG_URL:-}

}

setup_ibsrv_exec() {

    IBSRV_EXEC="gosu usr1cv8 ibsrv"
    IBSRV_EXEC+=" --direct-regport=${OC_IBSRV_PORT}"
    IBSRV_EXEC+=" --direct-range=${OC_IBSRV_RANGE_PORT}"
    IBSRV_EXEC+=" --direct-seclevel=${OC_IBSRV_SECLEVEL}"
    if [ -n "${OC_IBSRV_DEBUG}" ]; then
        IBSRV_EXEC+=" --debug=${OC_IBSRV_DEBUG}";
        IBSRV_EXEC+=" --debug-address=${OC_IBSRV_DEBUG_ADDRESS}";
        IBSRV_EXEC+=" --debug-port=${OC_IBSRV_DEBUG_PORT}";
        if [ -n "${OC_IBSRV_DEBUG_PASSWORD}" ]; then IBSRV_INIT_EXEC+=" --debug-password=${OC_IBSRV_DEBUG_PASSWORD}"; fi
        if [ -n "${OC_IBSRV_DEBUG_URL}" ];      then IBSRV_INIT_EXEC+=" --debug-server-url=${OC_IBSRV_DEBUG_URL}"; fi
    else
        IBSRV_EXEC+=" --debug=none";
    fi
    IBSRV_EXEC+=" --config=${OC_IBSRV_CONFIG_PATH}"

}

setup_ibsrv_init_exec() {

    IBSRV_INIT_EXEC="gosu usr1cv8 ibcmd server config init"
    IBSRV_INIT_EXEC+=" --http-address=${OC_IBSRV_HTTP_ADRESS}"
    IBSRV_INIT_EXEC+=" --http-port=${OC_IBSRV_HTTP_PORT}"
    IBSRV_INIT_EXEC+=" --http-base=${OC_IBSRV_HTTP_BASE_NAME}"
    IBSRV_INIT_EXEC+=" --name=${OC_IBSRV_BASE_NAME}"
    IBSRV_INIT_EXEC+=" --distribute-licenses=allow"
    IBSRV_INIT_EXEC+=" --schedule-jobs=allow"
    IBSRV_INIT_EXEC+=" --disable-local-speech-to-text=false"
    if [ -n "${OC_IBSRV_DBMS_KIND}" ]; then
        IBSRV_INIT_EXEC+=" --dbms=${OC_IBSRV_DBMS_KIND}";
        IBSRV_INIT_EXEC+=" --database-server=${OC_IBSRV_DBMS_ADRESS}";
        IBSRV_INIT_EXEC+=" --database-name=${OC_IBSRV_DBMS_NAME}";
        IBSRV_INIT_EXEC+=" --database-user=${OC_IBSRV_DBMS_LOGIN}";
        IBSRV_INIT_EXEC+=" --database-password=${OC_IBSRV_DBMS_PASSWORD}";
    else
        IBSRV_INIT_EXEC+=" --database-path=${OC_IBSRV_FILE_BASE_PATH}";
    fi
    IBSRV_INIT_EXEC+=" --out=${OC_IBSRV_CONFIG_PATH}"

}

init_ibsrv_config() {

    OC_IBSRV_CONFIG_DIR="$(dirname "${OC_IBSRV_CONFIG_PATH}")"
    if [ ! -d "${OC_IBSRV_CONFIG_DIR}" ]; then
        mkdir -p "${OC_IBSRV_CONFIG_DIR}";
    fi;
    chown -R usr1cv8:grp1cv8 "${OC_IBSRV_CONFIG_DIR}"

    if [ ! -f "${OC_IBSRV_CONFIG_PATH}" ]; then
        echo "Init ibsrv";
        echo "${IBSRV_INIT_EXEC}";
        ${IBSRV_INIT_EXEC} 2>&1;
    fi;

    cat "${OC_IBSRV_CONFIG_PATH}"

    if [ -z "${OC_IBSRV_DBMS_KIND}" ]; then
        if [ ! -d "${OC_IBSRV_FILE_BASE_PATH}" ]; then
            mkdir -p "${OC_IBSRV_FILE_BASE_PATH}"
            chown usr1cv8:grp1cv8 "${OC_IBSRV_FILE_BASE_PATH}"
            gosu usr1cv8 ibcmd infobase create --database-path="${OC_IBSRV_FILE_BASE_PATH}"
            if [ ! -f "${OC_IBSRV_FILE_BASE_PATH}" ]; then
                gosu usr1cv8 ibcmd infobase create --database-path="${OC_IBSRV_FILE_BASE_PATH}"
            fi;
        else
            chown -R usr1cv8:grp1cv8 "${OC_IBSRV_FILE_BASE_PATH}"
        fi;
    fi;

}

run_ibsrv_exec() {

    echo "Begining ibsrv"
    echo "${IBSRV_EXEC}"

    exec ${IBSRV_EXEC} 2>&1

}

ibsrv() {

    setup_ibsrv_defaults
    setup_ibsrv_exec
    setup_ibsrv_init_exec

    setup_init
    setup_ibsrv_healthcheck

    init_ibsrv_config
    run_ibsrv_exec

}

# crserver

setup_crserver_healthcheck() {

    if [ ! -f "/healthcheck.sh" ]; then
        echo "curl http://${OC_CRSERVER_HOSTNAME}/${OC_CRSERVER_LOCATION}" > /healthcheck.sh
        chmod 766 /healthcheck.sh
    fi;

}

setup_defaults_crserver() {

    WWW_PATH=${WWW_PATH:-"/var/www"}

    OC_CRSERVER_HOSTNAME=${OC_CRSERVER_HOSTNAME:-"localhost"}
    OC_CRSERVER_LOCATION=${OC_CRSERVER_LOCATION:-"repository/repository.1ccr"}
    OC_CRS_PORT=${OC_CRS_PORT:-"1542"}
    OC_CRSERVER_PATH=${WWW_PATH}/${OC_CRSERVER_LOCATION}

}

setup_crserver_exec() {

    OC_CRSERVER_EXEC="gosu usr1cv8 crserver"
    OC_CRSERVER_EXEC+=" -port ${OC_CRS_PORT}";
    OC_CRSERVER_EXEC+=" -d /home/usr1cv8/crserver"

    IFS='/' read -r -a OC_CRSERVER_PARTS <<< "${OC_CRSERVER_LOCATION}"

    if [ ! -f "${OC_CRSERVER_PATH}" ]; then
        mkdir -p "${WWW_PATH}/${OC_CRSERVER_PARTS[0]}";
        touch "${WWW_PATH}/${OC_CRSERVER_PARTS[0]}/index.html";
        touch "${OC_CRSERVER_PATH}";
        chown -R www-data:www-data "${WWW_PATH}/${OC_CRSERVER_PARTS[0]}";
        printf "%s\n" \
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" \
            "<repository connectString=\"tcp://${OC_CRSERVER_HOSTNAME}\"/>" \
        | tee "${OC_CRSERVER_PATH}";
    fi;

    if [ ! -f "/etc/apache2/conf-available/${OC_CRSERVER_PARTS[0]}.conf" ]; then
        printf "%s\n" \
            "AddHandler 1cws-process .1ccr" \
            "Alias \"/${OC_CRSERVER_PARTS[0]}\" \"${WWW_PATH}/${OC_CRSERVER_PARTS[0]}/\"" \
            "<Directory ${WWW_PATH}/${OC_CRSERVER_PARTS[0]}>" \
            "        DirectorySlash Off" \
            "        SetHandler 1cws-process" \
            "        ManagedApplicationDescriptor \"${OC_CRSERVER_PATH}\"" \
            "        Order allow,deny" \
            "        Allow from All" \
            "</Directory>" \
        | tee "/etc/apache2/conf-available/${OC_CRSERVER_PARTS[0]}.conf";
        ln -s "/etc/apache2/conf-available/${OC_CRSERVER_PARTS[0]}.conf" "/etc/apache2/conf-enabled/${OC_CRSERVER_PARTS[0]}.conf";
    fi;

    if ! grep -q "ServerName" /etc/apache2/apache2.conf; then
        echo "ServerName ${OC_CRSERVER_HOSTNAME}" >> /etc/apache2/apache2.conf
    fi;

}

setup_apache_exec() {

    APACHE_EXEC="service apache2 start"

}

run_apache_service() {

    echo "Begining Apache service"
    ${APACHE_EXEC} 2>&1

}

run_crserver_exec() {

    echo "Begining CRServer"
    echo "${OC_CRSERVER_EXEC}"
    exec ${OC_CRSERVER_EXEC} 2>&1

}

crserver() {

    setup_defaults_crserver
    setup_crserver_exec
    setup_apache_exec

    setup_init
    setup_crserver_healthcheck

    run_apache_service
    run_crserver_exec

}

# client

setup_client_healthcheck() {

    if [ ! -f "/healthcheck.sh" ]; then
        echo "ps -ef | grep Xvfb | grep -v grep" > /healthcheck.sh
        chmod 766 /healthcheck.sh
    fi;

}

setup_xvfb_exec() {

    XVFB_EXEC="/usr/bin/Xvfb :99 -screen 0 1024x768x24"

}

setup_client_exec() {

    CLIENT_EXEC=""

}

run_xvfb_exec_background() {

    echo "Begining Xvfb in background"
    ${XVFB_EXEC} 2>&1 &

}

run_client_exec() {

    echo "Begining client"
    echo "${CLIENT_EXEC}"
    exec ${CLIENT_EXEC} 2>&1

}

client() {

    setup_client_healthcheck

    setup_xvfb_exec
    setup_client_exec "$1"

    setup_init

    run_xvfb_exec_background
    run_client_exec

}

if [ "$1" == "sh" ]; then
    exec sh
elif [ "$1" == "bash" ]; then
    exec /bin/bash
else
    if [ "$1" = "server" ]; then
        server
    elif [ "$1" = "ibsrv" ]; then
        ibsrv
    elif [ "$1" = "crserver" ]; then
        crserver
    elif [ "$1" = "client" ]; then
        client "$2"
    else
        setup_init
        exec /bin/bash
    fi;
fi

exit 0