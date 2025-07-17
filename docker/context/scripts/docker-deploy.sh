#!/bin/bash

if [ ! -f ".env" ]; then
    echo "The environment file '.env' is missing"
    exit 1
else
    cat ".env"
    echo ""
fi

if [ "$1" = "compose" ]; then
  echo ""
  echo "docker compose up -d"
elif [ "$1" = "deploy" ]; then
  export "$(cat .env)" > /dev/null 2>&1;
  echo ""
  echo "docker stack deploy -c docker-stack.yml $2"
fi
