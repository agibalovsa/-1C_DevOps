#!/usr/bin/env bash

set -Eeo pipefail

# pks

setup_p12() {

    openssl pkcs12 -export \
      -in "${CERT_PATH}/${DOMAIN_NAME}.crt" \
      -inkey "${CERT_PATH}/${DOMAIN_NAME}.key" \
      -out "${CERT_PATH}/${DOMAIN_NAME}.p12" \
      -name nexus \
      -passout pass:changeit
   
}

setup_jks() {

    setup_p12

    keytool -importkeystore \
      -srckeystore "${CERT_PATH}/${DOMAIN_NAME}.p12" \
      -srcstoretype PKCS12 \
      -srcstorepass changeit \
      -destkeystore "${CERT_PATH}/${DOMAIN_NAME}.jks" \
      -deststoretype JKS \
      -deststorepass changeit \
      -alias nexus \
      -noprompt

    rm -f "${CERT_PATH}/${DOMAIN_NAME}.p12"
    
}

# step ca

setup_defaults() {

    USER_DOMAIN_ID=${USER_DOMAIN_ID:-"1001"}
    GROUP_DOMAIN_ID=${GROUP_DOMAIN_ID:-"1001"}
    STEP_CA_HOME="/root/.step"
    CERT_PATH=${CERT_PATH:-"${STEP_CA_HOME}/certs"}
    CONF_PATH=${CONF_PATH:-"${STEP_CA_HOME}/config"}
    WEB_ROOT=${WEB_ROOT:-"/usr/share/nginx/html"}
    SEND_SIG=${SEND_SIG:-"0"}
    SIGNAL=${SIGNAL:-"kill?signal=SIGHUP"}
    CERT_FORMAT=${CERT_FORMAT:-"CRT"}
    BACKGROUND=${BACKGROUND:-"0"}

    mkdir -p "${CERT_PATH}"
    mkdir -p "${CONF_PATH}"

}

setup_step_ca_healthcheck() {

    if [ ! -f "/healthcheck.sh" ]; then
        printf "%s\n" \
        "#!/bin/bash" \
        "step ca health" \
        "step certificate verify ${CERT_PATH}/${DOMAIN_NAME}.crt" \
        | tee "/healthcheck.sh";
        chmod +x "/healthcheck.sh"
    fi;

}

setup_step_ca_bootstrap() {

    if [ ! -f "${CONF_PATH}/defaults.json" ]; then
        step ca bootstrap \
          --force --ca-url "${STEP_URL}" \
          --fingerprint "${STEP_FINGERPRINT}";
    fi;

    step certificate install "${CERT_PATH}/root_ca.crt"

    setup_cert_access

}

setup_step_ca_certificate() {

    if [ ! -f "${CERT_PATH}/${DOMAIN_NAME}.crt" ]; then

        STEP_CA_CERT=( step ca certificate )
        STEP_CA_CERT+=( --force )
        if ss -tulnp | grep ":80" ; then
            STEP_CA_CERT+=( --webroot="${WEB_ROOT}" )
        else
            STEP_CA_CERT+=( --standalone )
        fi;
        STEP_CA_CERT+=( --provisioner acme "${DOMAIN_NAME}" )
        STEP_CA_CERT+=( "${CERT_PATH}/${DOMAIN_NAME}.crt" "${CERT_PATH}/${DOMAIN_NAME}.key" )

        exec "${STEP_CA_CERT[@]}" 2>&1

        setup_cert_access

    fi

}

setup_step_ca_renew_exec() {

    STEP_CA_EXEC=( step ca renew )
    if [ "${SEND_SIG}" != "0" ]; then STEP_CA_EXEC+=( --exec="/send_signal.sh" ); fi
    STEP_CA_EXEC+=( --daemon "${CERT_PATH}/${DOMAIN_NAME}.crt" "${CERT_PATH}/${DOMAIN_NAME}.key" )

}

setup_cert_access() {

    if [ "${SEND_SIG}" != "0" ]; then
        chown "${USER_DOMAIN_ID}:${GROUP_DOMAIN_ID}" "${CERT_PATH}"/*
    fi;

}

run_setup_step_ca_renew() {

    echo "Beginning step ca renew";
    echo "${STEP_CA_EXEC[@]}"
    if [ "${BACKGROUND}" = "0" ]; then
        exec "${STEP_CA_EXEC[@]}" 2>&1
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

SEND_SIG() {

    if [ "${CERT_FORMAT}" = "JKS" ]; then
        setup_jks
    elif [ "${CERT_FORMAT}" = "P12" ]; then
        setup_p12
    fi;
    setup_cert_access
    curl --unix-socket "/var/run/docker.sock" -X POST "http://localhost/containers/${DOMAIN_NAME//./-}/${SIGNAL}"
    echo "Send signal \"${SIGNAL}\" ${DOMAIN_NAME//./-}"

}

setup_defaults
setup_step_ca_healthcheck

if [ "$1" = "renew" ]; then
    step_ca_renew
elif [ "$1" = "signal" ]; then
    SEND_SIG
else
    echo "Wrong parameter: $1" >&2
    exit 1
fi

exit 0