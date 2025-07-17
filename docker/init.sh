#!/usr/bin/env bash

# Initialisation dockers stack building script
#  $1 - Сomma-separated сertificates URL
#
init_build_stack () {

    local -n return_name=$1
    local -n return_paths=$2

    name=$(\
        dialog --ascii-lines --no-shadow --erase-on-exit --output-fd 1 --title "Enter docker build stack" \
            --inputbox "" 8 40 \
    )

    IFS=" " read -ra paths <<< "$(
        dialog --ascii-lines --no-shadow --no-tags --erase-on-exit --output-fd 1 --radiolist "Please select applications" 0 0 0 \
            "os/linux_deb/build" "os-system" off \
            "imagick/build" "image magick" off \
            "postgrespro/build" "image magick" off \
            "jdk/build" "jdk" off \
            "1c/build" "1c platform" off \
            "1cesb/build" "1c-esb" off \
            "1cans/build" "1c-ans" off \
            "slc/build" "slc" off \
            "hasp/build" "hasp" off \
            "step-ca-cli/build" "step ca (cli)" off
    )"

    # shellcheck disable=SC2034
    return_name="${name}"
    # shellcheck disable=SC2034
    return_paths=( "${paths[@]}" )

}

# Creating dockers stack building script
#  $1 - Build stack name
#  $2 - Build stack applications
#
make_build_stack () {

    script_dir=$(dirname "$(readlink -f "$0")")

    if [ ! -d user_builds ]; then
        mkdir user_builds
    fi

    if [ ! -d "user_builds/${1}" ]; then
        mkdir "user_builds/${1}"
    fi

    set -a

    if [ -f "user_builds/${1}/.arg" ]; then
        # shellcheck disable=SC1091
        # shellcheck disable=SC1090
        source "user_builds/${1}/.arg"
        rm "user_builds/${1}/.arg"
    fi

    if [ -f "user_builds/${1}/docker-build.sh" ]; then
        rm "user_builds/${1}/docker-build.sh"
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
        "# shellcheck source=/dev/null" \
        "source \"\${CONTEXT_ARG}/.arg\"" \
        "" \
        | tee "user_builds/${1}/docker-build.sh.tmp" > /dev/null

    make_docker_build=0

    paths=( "${!2}" )
    for path in "${paths[@]}"
    do
        if [ -f "${script_dir}/${path}/docker-build.sh" ]; then
            {
                echo "cd ${script_dir}/${path}"
                echo "${script_dir}/${path}/docker-build.sh \"\$1\""
                echo ""
            } >> "user_builds/${1}/docker-build.sh.tmp"
            make_docker_build=1
        fi
        {
            echo "# ${path}"
            echo ""
            envsubst < "${path}/.arg.tmpl"
            echo ""
        } >> "user_builds/${1}/.arg.tmp"
    done

    set +a

    sed -i 's/{{/{/g' "user_builds/${1}/.arg.tmp"
    sed -i 's/}}/}/g' "user_builds/${1}/.arg.tmp"

    mv "user_builds/${1}/.arg.tmp" "user_builds/${1}/.arg"

    if [ ${make_docker_build} = 1 ]; then
        echo "rm -r \"\${CONTEXT_ARG}\"" >> "user_builds/${1}/docker-build.sh.tmp"
        mv "user_builds/${1}/docker-build.sh.tmp" "user_builds/${1}/docker-build.sh"
        chmod 744 "user_builds/${1}/docker-build.sh"
    else
        rm "user_builds/${1}/docker-build.sh.tmp"
    fi

}

set -Eeo pipefail

paths=( "common_context" )
make_build_stack "common_context" paths[@]

declare name_stack
# shellcheck disable=SC2034
declare -a paths_stack

init_build_stack name_stack paths_stack

make_build_stack "${name_stack}" paths_stack[@]
