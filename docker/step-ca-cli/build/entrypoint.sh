#!/usr/bin/env bash

set -Eeo pipefail

# step ca

setup_step_ca_healthcheck() {

    if [ ! -f "/healthcheck.sh" ]; then
        printf "%s\n" \
        "#!/bin/bash" \
        "step ca health" \
        "step certificate inspect ${CERT_PATH}/${DOMAIN_NAME}.crt --bundle > /dev/null 2>&1 || { echo 'CRITICAL: Certificate validation failed!' >&2; exit 1; }" \
        | tee "/healthcheck.sh";
        chmod +x "/healthcheck.sh"
    fi;

}

setup_step_ca_bootstrap() {

    if [ ! -f /root/.step/config/defaults.json ]; then
        step ca bootstrap \
          --force --ca-url "${STEP_URL}" \
          --fingerprint "${STEP_FINGERPRINT}";
    fi;

}

setup_defaults() {

    CERT_PATH=${CERT_PATH:-"/root/.step/certs"}
    mkdir -p "${CERT_PATH}"
    WEB_ROOT=${WEB_ROOT:-"/usr/share/nginx/html"}
    SEND_SIGHUP=${SEND_SIGHUP:-"0"}
    BACKGROUND=${BACKGROUND:-"0"}

}

setup_step_ca_certificate() {

    if [ ! -f "${CERT_PATH}/${DOMAIN_NAME}.crt" ]; then
        STEP_CA_CERT=( step ca certificate )
        STEP_CA_CERT+=( --force )
        if ss -tulnp | grep ":80" ; then
            STEP_CA_CERT+=( --webroot=${WEB_ROOT} )
        else
            STEP_CA_CERT+=( --standalone )
        fi;
        STEP_CA_CERT+=( --provisioner acme "${DOMAIN_NAME}" )
        STEP_CA_CERT+=( "${CERT_PATH}/${DOMAIN_NAME}.crt" "${CERT_PATH}/${DOMAIN_NAME}.key" )

        exec "${STEP_CA_CERT[@]}" 2>&1
    fi

}

setup_step_ca_renew_exec() {

    STEP_CA_EXEC=( step ca renew )
    if [ "${SEND_SIGHUP}" != "0" ]; then STEP_CA_EXEC+=( --exec="/send_sighup.sh" ); fi
    STEP_CA_EXEC+=( --daemon "${CERT_PATH}/${DOMAIN_NAME}.crt" "${CERT_PATH}/${DOMAIN_NAME}.key" )

}

run_setup_step_ca_renew() {

    echo "Beginning step ca renew";
    echo "${STEP_CA_EXEC[@]}"
    if [ "${BACKGROUND}" = "0" ]; then
        exec "${STEP_CA_EXEC[@]}" 2>&1;
    else
        "${STEP_CA_EXEC[@]}" 2>&1 &
    fi;

}

step_ca_renew() {

    setup_step_ca_bootstrap
    setup_step_ca_certificate
    setup_step_ca_renew_exec

    run_setup_step_ca_renew

}

setup_defaults
setup_step_ca_healthcheck

if [ "$1" = "renew" ]; then
    step_ca_renew
else
    echo "Wrong parameter: $1" >&2
    exit 1
fi

exit 0