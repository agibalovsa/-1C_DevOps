#!/usr/bin/env bash

set -Eeo pipefail

# step ca

setup_step_ca_healthcheck() {

    if [ ! -f "/healthcheck.sh" ]; then
        echo "step ca health" >> "/healthcheck.sh"
        chmod 766 "/healthcheck.sh"
    fi;

}

setup_step_ca_bootstrap() {

    if [ ! -f /root/.step/config/defaults.json ]; then
        step ca bootstrap \
          --force --ca-url "${STEP_URL}" \
          --fingerprint "${STEP_FINGERPRINT}";
    fi;

}

setup_step_ca_certificate() {

    if [ ! -f "/root/.step/certs/${DOMAIN_NAME}.crt" ]; then
        step ca certificate \
        --force --standalone --provisioner acme "${DOMAIN_NAME}" \
        "/root/.step/certs/${DOMAIN_NAME}.crt" "/root/.step/certs/${DOMAIN_NAME}.key";
    fi;

}

setup_step_ca_exec() {

    STEP_CA_EXEC=( step ca renew --exec="/send_sighup.sh" --daemon "/root/.step/certs/${DOMAIN_NAME}.crt" "/root/.step/certs/${DOMAIN_NAME}.key" );

}

run_step_ca_exec() {

    echo "Begining step ca";
    echo "${STEP_CA_EXEC[@]}"
    exec "${STEP_CA_EXEC[@]}" 2>&1;

}

step_ca() {

    setup_step_ca_healthcheck

    setup_step_ca_bootstrap
    setup_step_ca_certificate
    setup_step_ca_exec

    run_step_ca_exec

}

if [ "$1" == "sh" ]; then
    exec sh
elif [ "$1" == "bash" ]; then
    exec /bin/bash
elif [ "$1" = "step_ca" ]; then
    step_ca
else
    exec /bin/bash
fi

exit 0