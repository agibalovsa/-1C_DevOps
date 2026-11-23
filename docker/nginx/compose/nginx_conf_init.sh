#!/bin/bash

sed 's/\benv "/getenv "/g' nginx_conf.tmpl | docker run --rm -i \
  --env-file .env \
  hairyhenderson/gomplate > nginx.conf

sed 's/\benv "/getenv "/g' stream_conf.tmpl | docker run --rm -i \
  --env-file .env \
  hairyhenderson/gomplate > stream.conf
