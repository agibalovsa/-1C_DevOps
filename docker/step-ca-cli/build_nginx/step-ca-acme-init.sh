#!/bin/sh

set -e

while ! pidof nginx > /dev/null; do
  sleep 3;
  echo "Waiting start nginx";
done;

if [ ! -f /root/.step/config/defaults.json ]; then
  echo \
  $(step ca bootstrap \
    --force --ca-url $STEP_URL \
    --fingerprint $STEP_FINGERPRINT);
fi;

if [ ! -f /root/.step/certs/$DOMAIN_NAME.crt ]; then
  echo \
  $(step ca certificate \
    --force --provisioner acme $DOMAIN_NAME \
    /root/.step/certs/$DOMAIN_NAME.crt /root/.step/certs/$DOMAIN_NAME.key \
    --webroot=/usr/share/nginx/html);
fi;

service step-ca-acme start
service step-ca-acme status

sleep 3

cat /var/log/step-ca-acme.log | tail -n 1