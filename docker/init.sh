#!/usr/bin/env bash

# Initialization dockers stack building script
#
init_stack () {

    local -n return_name=$1
    local -n return_type=$2
    local -n return_paths=$3
    local -n return_use_env_file=$4

    # shellcheck disable=SC2143
    [[ $(dialog --help | grep -- "--erase-on-exit") ]] && ERASE_ON_EXIT="--erase-on-exit" || :

    name=$(\
        dialog --ascii-lines --no-shadow ${ERASE_ON_EXIT} --output-fd 1 --title "Enter docker project name" \
            --inputbox "" 8 40 \
    )

    if [ -z "${ERASE_ON_EXIT}" ]; then
        clear;
    fi

    type=$(\
        dialog --ascii-lines --no-shadow --no-tags ${ERASE_ON_EXIT} --output-fd 1 --radiolist "Please select type" 0 0 0 \
            "build" "build" on \
            "compose" "compose" off \
            "stack" "stack" off \
    )

    if [ -z "${ERASE_ON_EXIT}" ]; then
        clear;
    fi

    if [ "${type}" = "compose" ]; then
        IFS=" " read -ra paths <<< "$(
            dialog --ascii-lines --no-shadow --no-tags ${ERASE_ON_EXIT} --output-fd 1 --checklist "Please select applications" 0 0 0 \
                "1c/compose/crs" "1C Platform (cr-server)" off \
                "1c/compose/ibsrv" "1C Platform (ibsrv)" off \
                "1c/compose/server" "1C Platform (server)" off \
                "1c-ans/compose" "1C Ans" off \
                "1c-element/compose" "1C Element" off \
                "gitlab-ce/compose" "Gitlab" off \
                "hasp/compose" "Hasp" off \
                "fluent-bit/compose" "Fluent Bit" off \
                "opensearch/compose" "Open Search" off \
                "portainer/compose" "Portainer" off \
                "postgres/compose" "Postgres" off \
                "slc/compose" "Slc" off \
                "sonarqube/compose" "Sonarqube" off \
                "step-ca-cli/compose" "Step CA (cli)" off
        )"
    elif [ "${type}" = "stack" ]; then
        IFS=" " read -ra paths <<< "$(
            dialog --ascii-lines --no-shadow --no-tags ${ERASE_ON_EXIT} --output-fd 1 --checklist "Please select applications" 0 0 0 \
                "1c/compose/server" "1C Platform (server)" off \
                "gitlab-ce/compose" "Gitlab" off \
                "opensearch/compose" "Open Search" off \
                "portainer/compose" "Portainer" off \
                "postgres/compose" "Postgres" off \
                "sonarqube/compose" "Sonarqube" off
        )"
    else
        IFS=" " read -ra paths <<< "$(
            dialog --ascii-lines --no-shadow --no-tags ${ERASE_ON_EXIT} --output-fd 1 --radiolist "Please select applications" 0 0 0 \
                "1c/build/linux" "1C Platform" off \
                "1c-ans/build" "1C Ans" off \
                "1c-element/build" "1C Element" off \
                "1c-element-script/build" "1C Element (Script)" off \
                "deb-builder/build" "Deb builder" off \
                "gitlab-ce/build/gitlab-auto-mr" "Gitlab MR" off \
                "hasp/build" "Hasp" off \
                "imagick/build" "Image Magick" off \
                "jdk/build" "JDK" off \
                "nginx/build" "Nginx" off \
                "openssl/build" "OpenSSL" off \
                "os/linux_deb/build" "OS System" off \
                "oscript/build" "One Script" off \
                "postgres/build" "Postgres" off \
                "slc/build" "Slc" off \
                "sonarqube/build" "Sonarqube" off \
                "step-ca-cli/build" "Step CA (cli)" off \
                "vanessa-automation/build" "Vanessa automation" off
        )"
    fi;

    if [ -z "${ERASE_ON_EXIT}" ]; then
        clear;
    fi

    if [ "${type}" = "compose" ] || [ "${type}" = "stack" ]; then

        add_compose=()
        current_dir=$(dirname "$(readlink -f "$0")")
        
        for path in "${paths[@]}"
        do
            search_compose="${current_dir}/${path}/*/*${type}.yml"
            for compose_file in ${search_compose};
            do
                if [ ! "${compose_file}" == "${search_compose}" ] ; then
                    compose_path="$( dirname "${compose_file}") $( dirname "${compose_file}") off\n"
                    # shellcheck disable=SC2076
                    if [[ ! $(IFS=$'|'; echo "|${add_compose[*]}|") =~ "|${compose_path}|" ]]; then
                        add_compose+=( "${compose_path}" )
                    fi
                fi
            done
        done

        if [ ${#add_compose[@]} -gt 0 ]; then
            # shellcheck disable=SC2068
            selected_files=$(dialog --ascii-lines --no-shadow --no-tags ${ERASE_ON_EXIT} --output-fd 1 --checklist "Please select additional ${type}" 0 0 0 ${add_compose[@]} )
        fi;
        if [ -n "${selected_files}" ]; then
            paths+=( "${selected_files[@]}" )
        fi

        if [ -z ${ERASE_ON_EXIT} ]; then
            clear;
        fi

        use_env_file=$(
            dialog --ascii-lines --no-shadow --no-tags ${ERASE_ON_EXIT} --output-fd 1 --radiolist "Use .env file" 0 0 0 \
                "1" "Yes" on \
                "0" "No" off 
        )
        
    fi
    
    # shellcheck disable=SC2034
    return_name="${name}"
    # shellcheck disable=SC2034
    return_type="${type}"
    # shellcheck disable=SC2034
    return_paths=( "${paths[@]}" )
    # shellcheck disable=SC2034
    return_use_env_file=${use_env_file}

}

# Creating docker stack scripts (Compose or stack)
#  $1 - Stack type ("compose" or "stack", defaults to "compose")
#  $2 - Stack name
#  $3 - Stack applications (array reference)
#  $4 - Use .env file
#
make_run_stack () {
    
    stack_type="${1:-compose}"
    stack_name="${2}"
    use_env_file_stack=${4}
    
    current_dir=$(dirname "$(readlink -f "$0")")
    
    if [ "${stack_type}" = "stack" ]; then
        stack_path="${current_dir}/users/stack/${stack_name}"
        type_dir="stack"
        flag="-c"
        up_script="docker-stack.sh"
        down_script="docker-stack-rm.sh"
        logs_script=""
    else
        stack_path="${current_dir}/users/compose/${stack_name}"
        type_dir="compose"
        flag="-f"
        up_script="docker-compose-up.sh"
        down_script="docker-compose-down.sh"
        logs_script="docker-compose-logs.sh"
    fi

    if [ ! -d "${stack_path:?}" ]; then
        mkdir -p "${stack_path:?}"
    fi

    set -a

    if [ -f "${stack_path}/.env" ]; then
        # shellcheck disable=SC1091
        # shellcheck disable=SC1090
        [ "${use_env_file_stack}" = "1" ] && source "${stack_path}/.env"
        rm "${stack_path}/.env"
    fi

    [ -f "${stack_path}/${up_script}" ] && rm "${stack_path}/${up_script}"
    [ -f "${stack_path}/${down_script}" ] && rm "${stack_path}/${down_script}"
    [ -n "${logs_script}" ] && [ -f "${stack_path}/${logs_script}" ] && rm "${stack_path}/${logs_script}"

    if [ "${use_env_file_stack}" = "1" ] && [ -d "${stack_path:?}/${stack_name}" ]; then
        rm -r "${stack_path:?}/${stack_name}"
    fi

    printf "%s\n" \
        "#!/bin/bash" \
        "" \
        "set -Eeoa pipefail" \
        "" \
        "current_dir=\$(dirname \"\$(readlink -f \"\$0\")\")" \
        "CONTEXT_ENV=\$(realpath \"\${current_dir}/${stack_name}\")" \
        "" \
    | tee "${stack_path}/${up_script}.tmp" > /dev/null;
    
    if [ "${use_env_file_stack}" = "1" ]; then
        {
            echo "mkdir -p \"\${current_dir}/${stack_name}\""
            echo "# make context file"
            echo ""
            echo "{"
            echo "    echo \"CONTEXT_ENV=\${CONTEXT_ENV}\""
            echo "    echo \"\""
            echo "    cat \"\${current_dir}/../common_context/.env\""
            echo "    echo \"\""
            echo "    cat \"\${current_dir}/.env\""
            echo "} > \"\${CONTEXT_ENV}/.env\""
            echo ""
        } >> "${stack_path}/${up_script}.tmp"
    else
        mkdir -p "${stack_path}/${stack_name}"
    fi

    printf "%s\n" \
        "#!/bin/bash" \
        "" \
        "set -Eeoa pipefail" \
        "" \
        "current_dir=\$(dirname \"\$(readlink -f \"\$0\")\")" \
        "CONTEXT_ENV=\$(realpath \"\${current_dir}/${stack_name}\")" \
        "" \
    | tee "${stack_path}/${down_script}.tmp" > /dev/null;

    if [ -n "${logs_script}" ]; then
        printf "%s\n" \
            "#!/bin/bash" \
            "" \
            "set -Eeoa pipefail" \
            "" \
            "current_dir=\$(dirname \"\$(readlink -f \"\$0\")\")" \
            "CONTEXT_ENV=\$(realpath \"\${current_dir}/${stack_name}\")" \
            "" \
        | tee "${stack_path}/${logs_script}.tmp" > /dev/null;
    fi

    compose_files=""

    paths=( "${!3}" )
    for path in "${paths[@]}"
    do
        rel_path="${path#"${current_dir}"/}"
        proj_name=$(echo "${rel_path/\/${type_dir}/}" | tr '/' '-')
        proj_name=${proj_name//-compose-/-}
        proj_name=${proj_name%-compose}
        for file in "${current_dir}/${rel_path}/"* "${current_dir}/${rel_path}/".*
        do
            if [[ "${file}" == *"configs" ]]; then
                [ "${use_env_file_stack}" = "0" ] && (
                    cp -r "${file}" "${stack_path}/${stack_name}"
                )
                [ "${use_env_file_stack}" = "1" ] && {
                    echo "cp -r ${file} \"\${CONTEXT_ENV}/\""
                } >> "${stack_path}/${up_script}.tmp"
            elif [ -d "${file}" ]; then
                continue
            elif [[ "${file}" == *".*" ]]; then
                continue
            elif [[ "${file}" == *".ps1" ]]; then
                continue
            elif [[ "${file}" == *"common-compose.yml" ]]; then
                [ "${use_env_file_stack}" = "0" ] && (
                    envsubst < "${file}" > "${stack_path}/${stack_name}/common-compose-${proj_name}.yml"
                )
                [ "${use_env_file_stack}" = "1" ] && {
                    echo "cp ${file} \"\${CONTEXT_ENV}/common-compose-${proj_name}.yml\""
                } >> "${stack_path}/${up_script}.tmp"
                compose_files="${compose_files} ${flag} common-compose-${proj_name}.yml"
            elif [[ "${stack_type}" == "compose" && "${file}" == *"docker-compose.yml" ]]; then
                [ "${use_env_file_stack}" = "0" ] && (
                    envsubst < "${file}" > "${stack_path}/${stack_name}/docker-compose-${proj_name}.yml"
                )
                [ "${use_env_file_stack}" = "1" ] && {
                    echo "cp ${file} \"\${CONTEXT_ENV}/docker-compose-${proj_name}.yml\""
                } >> "${stack_path}/${up_script}.tmp"
                compose_files="${compose_files} ${flag} docker-compose-${proj_name}.yml"
            elif [[ "${stack_type}" == "stack" && "${file}" == *"docker-stack.yml" ]]; then
                [ "${use_env_file_stack}" = "0" ] && (
                    envsubst < "${file}" > "${stack_path}/${stack_name}/docker-stack-${proj_name}.yml"
                )
                [ "${use_env_file_stack}" = "1" ] && {
                    echo "cp ${file} \"\${CONTEXT_ENV}/docker-stack-${proj_name}.yml\""
                } >> "${stack_path}/${up_script}.tmp"
                compose_files="${compose_files} ${flag} docker-stack-${proj_name}.yml"
            elif [[ "${stack_type}" == "compose" && "${file}" == *"stack.yml" ]]; then
                continue
            elif [[ "${stack_type}" == "stack" && "${file}" == *"compose.yml" ]]; then
                continue
            elif [[ "${file}" == *".env.tmpl" ]]; then
                [ "${use_env_file_stack}" = "1" ] && {
                    echo "# # ${proj_name}"
                    echo ""
                    envsubst < "${current_dir}/${rel_path}/.env.tmpl"
                    echo ""
                } >> "${stack_path}/.env.tmp"
            else
                filename=$(basename "${file}")
                [ "${use_env_file_stack}" = "0" ] && (
                    envsubst < "${file}" > "${stack_path}/${stack_name}/${filename}"
                )
                [ "${use_env_file_stack}" = "1" ] && {
                    echo "cp ${file} \"\${CONTEXT_ENV}/${filename}\""
                } >> "${stack_path}/${up_script}.tmp"
                if [[ "${stack_type}" == "compose" && "${file}" == *"compose.yml" ]] || \
                [[ "${stack_type}" == "stack" && "${file}" == *"stack.yml" ]]; then
                    compose_files="${compose_files} ${flag} ${filename}"
                fi
            fi
        done
    done

    if [ -n "${compose_files}" ]; then
        if [ "${stack_type}" = "stack" ]; then
            {
                echo ""
                echo "cd \"\${CONTEXT_ENV}\""
                [ "${use_env_file_stack}" = "1" ] && echo "export \$(cat .env | xargs)"
                echo "docker stack deploy ${compose_files} ${stack_name}"
                echo "cd .."
            } >> "${stack_path}/${up_script}.tmp"

            {
                echo "if [ -d \"\${CONTEXT_ENV}\" ]; then"
                echo "    docker stack rm ${stack_name}"
                echo "    rm \"\${CONTEXT_ENV}\"/.env"
                echo "fi"
            } >> "${stack_path}/${down_script}.tmp"
        else
            {
                echo ""
                echo "cd \"\${CONTEXT_ENV}\""
                echo "docker compose ${compose_files} up -d"
                echo "cd .."
            } >> "${stack_path}/${up_script}.tmp"

            {
                echo "if [ -d \"\${CONTEXT_ENV}\" ]; then"
                echo "    cd \"\${CONTEXT_ENV}\""
                echo "    docker compose ${compose_files} down"
                echo "    cd .."
                echo "    rm \"\${CONTEXT_ENV}\"/.env"
                echo "fi"
            } >> "${stack_path}/${down_script}.tmp"

            {
                echo "if [ -d \"\${CONTEXT_ENV}\" ]; then"
                echo "    cd \"\${CONTEXT_ENV}\""
                echo "    docker compose ${compose_files} logs --follow"
                echo "    cd .."
                echo "fi"
            } >> "${stack_path}/${logs_script}.tmp"
        fi
    fi

    set +a

    if [ "${use_env_file_stack}" = "1" ] && [ -f "${stack_path}/.env.tmp" ]; then
        sed -i 's/{{/{/g' "${stack_path}/.env.tmp"
        sed -i 's/}}/}/g' "${stack_path}/.env.tmp"
        mv "${stack_path}/.env.tmp" "${stack_path}/.env"
    fi

    if [ -n "${compose_files}" ]; then
        mv "${stack_path}/${up_script}.tmp" "${stack_path}/${up_script}"
        chmod 744 "${stack_path}/${up_script}"
        mv "${stack_path}/${down_script}.tmp" "${stack_path}/${down_script}"
        chmod 744 "${stack_path}/${down_script}"
        if [ -n "${logs_script}" ]; then
            mv "${stack_path}/${logs_script}.tmp" "${stack_path}/${logs_script}"
            chmod 744 "${stack_path}/${logs_script}"
        fi
    else
        rm "${stack_path}/${up_script}.tmp"
        rm "${stack_path}/${down_script}.tmp"
        [ -n "${logs_script}" ] && rm "${stack_path}/${logs_script}.tmp"
    fi
}

# Creating dockers stack building script
#  $1 - Stack name
#  $2 - Stack applications
#
make_build_stack () {

    current_dir=$(dirname "$(readlink -f "$0")")
    stack_path="${current_dir}/users/builds/${1}"

    if [ ! -d "${stack_path:?}" ]; then
        mkdir -p "${stack_path:?}"
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
        "current_dir=\$(dirname \"\$(readlink -f \"\$0\")\")" \
        "" \
        "# make context file" \
        "mkdir -p \"\${current_dir}/context\"" \
        "CONTEXT_ARG=\$(realpath \"\${current_dir}/context\")" \
        "CONTEXT_SECRET=\$(realpath \"\${current_dir}/.secret\")" \
        "{" \
            "echo \"CONTEXT_ARG=\${CONTEXT_ARG}\"" \
            "echo \"CONTEXT_SECRET=\${CONTEXT_SECRET}\"" \
            "echo \"\"" \
            "cat \"\${current_dir}/../common_context/.arg\"" \
            "echo \"\"" \
            "cat \"\${current_dir}/.arg\"" \
        "} > \"\${CONTEXT_ARG}/.arg\"" \
        "" \
        "# shellcheck source=/dev/null" \
        "source \"\${CONTEXT_ARG}/.arg\"" \
        "" \
        | tee "${stack_path}/docker-build.sh.tmp" > /dev/null

    make_docker_build=0

    paths=( "${!2}" )
    for path in "${paths[@]}"
    do
        if [ -f "${current_dir}/${path}/docker-build.sh" ]; then
            {
                echo "if [ -d \"\${current_dir}/distr\" ]; then"
                echo "    cp -r \"\${current_dir}/distr\" \"${current_dir}/${path}/context\""
                echo "fi"
                echo "cd \"${current_dir}/${path}\""
                echo "${current_dir}/${path}/docker-build.sh \"\$1\" \"\$2\""
                echo ""
            } >> "${stack_path}/docker-build.sh.tmp"
            make_docker_build=1
        fi
        {
            echo "# # ${path}"
            echo ""
            # https://github.com/a8m/envsubst (interpolating default values in file)
            envsubst < "${current_dir}/${path}/.arg.tmpl"
            echo ""
        } >> "${stack_path}/.arg.tmp"
        if [ -f "${current_dir}/${path}/.secret.tmpl" ]; then
            {
                echo "# # ${path}"
                echo ""
                # https://github.com/a8m/envsubst (interpolating default values in file)
                envsubst < "${current_dir}/${path}/.secret.tmpl"
                echo ""
            } >> "${stack_path}/.secret.tmp"
        fi
    done

    set +a

    sed -i 's/{{/{/g' "${stack_path}/.arg.tmp"
    sed -i 's/}}/}/g' "${stack_path}/.arg.tmp"
    mv "${stack_path}/.arg.tmp" "${stack_path}/.arg"

    if [ -f "${stack_path}/.secret.tmp" ]; then
        sed -i 's/{{/{/g' "${stack_path}/.secret.tmp"
        sed -i 's/}}/}/g' "${stack_path}/.secret.tmp"
        mv "${stack_path}/.secret.tmp" "${stack_path}/.secret"
    fi

    if [ ${make_docker_build} = 1 ]; then
        {
            echo "rm -r \"\${CONTEXT_ARG}\""
            echo "if [ -d \"${current_dir}/${path}/context/distr\" ]; then"
            echo "    rm -r \"${current_dir}/${path}/context/distr\""
            echo "fi"
        } >> "${stack_path}/docker-build.sh.tmp"
        mv "${stack_path}/docker-build.sh.tmp" "${stack_path}/docker-build.sh"
        chmod 744 "${stack_path}/docker-build.sh"
    else
        rm "${stack_path}/docker-build.sh.tmp"
    fi

}

set -Eeo pipefail

paths=( "common_context" )
make_build_stack "common_context" paths[@]
make_run_stack "" "common_context" paths[@]

declare name_stack
declare type_stack
# shellcheck disable=SC2034
declare -a paths_stack
declare use_env_file_stack

init_stack name_stack type_stack paths_stack use_env_file_stack

if [ -z "${name_stack}" ] || [ -z "${type_stack}" ] || [ "${#paths_stack[@]}" == 0 ]; then
    echo "Empty entries"
    exit 1
fi;

if [ "${type_stack}" = "build" ]; then
    make_build_stack "${name_stack}" paths_stack[@]
else
    make_run_stack "${type_stack}" "${name_stack}" paths_stack[@] "${use_env_file_stack}"
fi;