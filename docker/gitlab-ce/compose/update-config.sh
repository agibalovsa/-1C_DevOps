#!/bin/bash

if (docker config inspect gitlab_conf) ; then
    docker config rm gitlab_conf
fi;

docker config create --template-driver golang gitlab_conf gitlab_conf.tmpl