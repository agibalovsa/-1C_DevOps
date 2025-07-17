#!/bin/sh

set -e

sed -i 's@$DOMAIN_NAME@'"$DOMAIN_NAME"'@g' /etc/init.d/step-ca-acme

/step-ca-acme-init.sh &