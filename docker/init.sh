#!/usr/bin/env bash

# Initialization dockers stack building script
#
init_stack () {

    local -n return_name=$1
    local -n return_type=$2
    local -n return_paths=$3

    name=$(\
        dialog --ascii-lines --no-shadow --erase-on-exit --output-fd 1 --title "Enter docker build stack" \
            --inputbox "" 8 40 \
    )

    type=$(\
        dialog --ascii-lines --no-shadow --no-tags --erase-on-exit --output-fd 1 --radiolist "Please select type" 0 0 0 \
            "build" "build" off \
            "compose" "compose" off
    )

    if [ "${type}" = "compose" ]; then
        IFS=" " read -ra paths <<< "$(
            dialog --ascii-lines --no-shadow --no-tags --erase-on-exit --output-fd 1 --checklist "Please select applications" 0 0 0 \
                "1c/compose/crs" "1C Platform (cr-server)" off \
                "1c/compose/ibsrv" "1C Platform (ibsrv)" off \
                "1c/compose/server" "1C Platform (server)" off \
                "1cans/compose" "1C Ans" off \
                "1cesb/compose" "1C Esb" off \
                "hasp/compose" "Hasp" off \
                "opensearch/compose" "OpenSearch" off \
                "portainer/compose" "Portainer" off \
                "postgres/compose" "Postgres" off \
                "slc/compose" "Slc" off \
                "sonarqube/compose" "Sonarqube" off \
                "step-ca-cli/compose" "Step CA (cli)" off
        )"
    else
        IFS=" " read -ra paths <<< "$(
            dialog --ascii-lines --no-shadow --no-tags --erase-on-exit --output-fd 1 --radiolist "Please select applications" 0 0 0 \
                "1c/build" "1C Platform" off \
                "1cans/build" "1C Ans" off \
                "1cesb/build" "1C Esb" off \
                "1cexecutor/build" "1C Executor" off \
                "hasp/build" "Hasp" off \
                "imagick/build" "Image Magick" off \
                "jdk/build" "JDK" off \
                "nginx/build" "Nginx" off \
                "os/linux_deb/build" "OS System" off \
                "postgres/build" "Postgres" off \
                "slc/build" "Slc" off \
                "sonarqube/build" "Sonarqube" off \
                "step-ca-cli/build" "Step CA (cli)" off
        )"
    fi;



    # shellcheck disable=SC2034
    return_name="${name}"
    # shellcheck disable=SC2034
    return_type="${type}"
    # shellcheck disable=SC2034
    return_paths=( "${paths[@]}" )

}

# Creating dockers stack compose script
#  $1 - Stack name
#  $2 - Stack applications
#
make_compose_stack () {

    script_dir=$(dirname "$(readlink -f "$0")")
    stack_path="${script_dir}/users/compose/${1}"

    if [ ! -d "${stack_path}" ]; then
        mkdir -p "${stack_path}"
    fi

    set -a

    if [ -f "${stack_path}/.env" ]; then
        # shellcheck disable=SC1091
        # shellcheck disable=SC1090
        source "${stack_path}/.env"
        rm "${stack_path}/.env"
    fi

    if [ -f "${stack_path}/docker-compose.sh" ]; then
        rm "${stack_path}/docker-compose.sh"
    fi

    printf "%s\n" \
        "#!/bin/bash" \
        "" \
        "set -Eeoa pipefail" \
        "" \
        "script_dir=\$(dirname \"\$(readlink -f \"\$0\")\")" \
        "" \
        "# make context file" \
        "if [ -d \"\${script_dir}/context\" ]; then" \
        "    rm -r \"\${script_dir}/context\";" \
        "fi;" \
        "mkdir -p \"\${script_dir}/context\"" \
        "CONTEXT_ENV=\$(realpath \"\${script_dir}/context\")" \
        "{" \
            "echo \"CONTEXT_ENV=\${CONTEXT_ENV}\"" \
            "echo \"\"" \
            "cat \"\${script_dir}/../common_context/.env\"" \
            "echo \"\"" \
            "cat \"\${script_dir}/.env\"" \
        "} >> \"\${CONTEXT_ENV}/.env\"" \
        "" \
        | tee "${stack_path}/docker-compose-up.sh.tmp" > /dev/null;

    printf "%s\n" \
        "#!/bin/bash" \
        "" \
        "set -Eeoa pipefail" \
        "" \
        "script_dir=\$(dirname \"\$(readlink -f \"\$0\")\")" \
        "CONTEXT_ENV=\$(realpath \"\${script_dir}/context\")" \
        "" \
    | tee "${stack_path}/docker-compose-down.sh.tmp" > /dev/null;

    compose_files=""

    paths=( "${!2}" )
    for path in "${paths[@]}"
    do
        proj_name=$(echo "${path}" | awk -F/ '{print $1}')
        if [ -f "${script_dir}/${path}/common-compose.yml" ]; then
            {
                echo "cp ${script_dir}/${path}/common-compose.yml \"\${CONTEXT_ENV}/common-compose-${proj_name}.yml\""
                compose_files="${compose_files} -f common-compose-${proj_name}.yml"
            } >> "${stack_path}/docker-compose-up.sh.tmp"
        fi
        if [ -f "${script_dir}/${path}/docker-compose.yml" ]; then
            {
                echo "cp ${script_dir}/${path}/docker-compose.yml \"\${CONTEXT_ENV}/docker-compose-${proj_name}.yml\""
                compose_files="${compose_files} -f docker-compose-${proj_name}.yml"
            } >> "${stack_path}/docker-compose-up.sh.tmp"
        fi
        {
            echo "# ${path}"
            echo ""
            envsubst < "${script_dir}/${path}/.env.tmpl"
            echo ""
        } >> "${stack_path}/.env.tmp"
    done

    if [ -n "${compose_files}" ]; then
        {
            echo ""
            echo "cd \"\${CONTEXT_ENV}\""
            echo "docker compose ${compose_files} up -d"
            echo "cd .."
        }  >> "${stack_path}/docker-compose-up.sh.tmp"

        {
            echo "cd \"\${CONTEXT_ENV}\""
            echo "docker compose ${compose_files} down"
            echo "cd .."
        }  >> "${stack_path}/docker-compose-down.sh.tmp"
    fi

    set +a

    sed -i 's/{{/{/g' "${stack_path}/.env.tmp"
    sed -i 's/}}/}/g' "${stack_path}/.env.tmp"

    mv "${stack_path}/.env.tmp" "${stack_path}/.env"

    if [ -n "${compose_files}" ]; then
        mv "${stack_path}/docker-compose-up.sh.tmp" "${stack_path}/docker-compose-up.sh"
        chmod 744 "${stack_path}/docker-compose-up.sh"
        mv "${stack_path}/docker-compose-down.sh.tmp" "${stack_path}/docker-compose-down.sh"
        chmod 744 "${stack_path}/docker-compose-down.sh"
    else
        rm "${stack_path}/docker-compose-up.sh.tmp"
        rm "${stack_path}/docker-compose-down.sh.tmp"
    fi

}

# Creating dockers stack building script
#  $1 - Stack name
#  $2 - Stack applications
#
make_build_stack () {

    script_dir=$(dirname "$(readlink -f "$0")")
    stack_path="${script_dir}/users/builds/${1}"

    if [ ! -d "${stack_path}" ]; then
        mkdir -p "${stack_path}"
    fi

    set -a

    if [ -f "${stack_path}/.arg" ]; then
        # shellcheck disable=SC1091
        # shellcheck disable=SC1090
        source "${stack_path}/.arg"
        rm "${stack_path}/.arg"
    fi

    if [ -f "${stack_path}/docker-build.sh" ]; then
        rm "${stack_path}/docker-build.sh"
    fi

    printf "%s\n" \
        "#!/bin/bash" \
        "" \
        "set -Eeoa pipefail" \
        "" \
        "script_dir=\$(dirname \"\$(readlink -f \"\$0\")\")" \
        "" \
        "# make context file" \
        "mkdir -p \"\${script_dir}/context\"" \
        "CONTEXT_ARG=\$(realpath \"\${script_dir}/context\")" \
        "{" \
            "echo \"CONTEXT_ARG=\${CONTEXT_ARG}\"" \
            "echo \"\"" \
            "cat \"\${script_dir}/../common_context/.arg\"" \
            "echo \"\"" \
            "cat \"\${script_dir}/.arg\"" \
        "} >> \"\${CONTEXT_ARG}/.arg\"" \
        "" \
        "# shellcheck source=/dev/null" \
        "source \"\${CONTEXT_ARG}/.arg\"" \
        "" \
        | tee "${stack_path}/docker-build.sh.tmp" > /dev/null

    make_docker_build=0

    paths=( "${!2}" )
    for path in "${paths[@]}"
    do
        if [ -f "${script_dir}/${path}/docker-build.sh" ]; then
            {
                echo "cd ${script_dir}/${path}"
                echo "${script_dir}/${path}/docker-build.sh \"\$1\""
                echo ""
            } >> "${stack_path}/docker-build.sh.tmp"
            make_docker_build=1
        fi
        {
            echo "# ${path}"
            echo ""
            envsubst < "${script_dir}/${path}/.arg.tmpl"
            echo ""
        } >> "${stack_path}/.arg.tmp"
    done

    set +a

    sed -i 's/{{/{/g' "${stack_path}/.arg.tmp"
    sed -i 's/}}/}/g' "${stack_path}/.arg.tmp"

    mv "${stack_path}/.arg.tmp" "${stack_path}/.arg"

    if [ ${make_docker_build} = 1 ]; then
        echo "rm -r \"\${CONTEXT_ARG}\"" >> "${stack_path}/docker-build.sh.tmp"
        mv "${stack_path}/docker-build.sh.tmp" "${stack_path}/docker-build.sh"
        chmod 744 "${stack_path}/docker-build.sh"
    else
        rm "${stack_path}/docker-build.sh.tmp"
    fi

}

set -Eeo pipefail

paths=( "common_context" )
make_build_stack "common_context" paths[@]
make_compose_stack "common_context" paths[@]

declare name_stack
declare type_stack
# shellcheck disable=SC2034
declare -a paths_stack

init_stack name_stack type_stack paths_stack

if [ -z "${name_stack}" ] || [ -z "${type_stack}" ] || [ "${#paths_stack[@]}" == 0 ]; then
    echo "Empty entries"
    exit 1
fi;

if [ "${type_stack}" = "compose" ]; then
    make_compose_stack "${name_stack}" paths_stack[@]
else
    make_build_stack "${name_stack}" paths_stack[@]
fi;
