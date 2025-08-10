#!/bin/bash

if (docker config inspect nginx_conf) ; then
    docker config rm nginx_conf
fi;

docker config create --template-driver golang nginx_conf nginx_conf.tmpl