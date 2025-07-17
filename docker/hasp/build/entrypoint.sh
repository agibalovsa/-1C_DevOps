#!/usr/bin/env bash

set -Eeo pipefail

# hasp

setup_hasp_healthcheck() {

    if [ ! -f "/healthcheck.sh" ]; then
      # shellcheck disable=SC2016
      echo 'if [ "$(netstat -anp | grep hasp)" = "" ]; then echo "NOK"; exit 1; else echo "OK"; exit 0; fi' > /healthcheck.sh;
      chmod 766 /healthcheck.sh;
    fi;

}

setup_hasp_exec() {

    sed -i 's/SourceIfNotEmpty \/etc\/sysconfig\/haspd/SourceIfNotEmpty=\/etc\/sysconfig\/haspd/g' /etc/init.d/haspd;

}

run_hasp_exec() {

    echo "Begining hasp";
    service haspd start && tail -F /var/log/lastlog;

}

hasp() {

    setup_hasp_healthcheck

    setup_hasp_exec
    run_hasp_exec

}

if [ "$1" == "sh" ]; then
    exec sh
elif [ "$1" == "bash" ]; then
    exec /bin/bash
elif [ "$1" = "hasp" ]; then
    hasp
else
    exec /bin/bash
fi

exit 0