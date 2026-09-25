#!/usr/bin/env bash

set -Eeo pipefail

script_dir=$(dirname "$(readlink -f "$0")")

# shellcheck disable=SC1091
. "${script_dir}/../../scripts/dialog/dialog_lib.sh"
# shellcheck disable=SC1091
. "${script_dir}/../../scripts/1c/oc_lib.sh"
# shellcheck disable=SC1091
. "${script_dir}/../../scripts/aptly/aptly_lib.sh"

declare -A resultDialog

if open_dialog "${script_dir}/download-form.yml" resultDialog; then

    tmpInstallDeb="/tmp/install_deb"

    if ! ls "${tmpInstallDeb}"/*"${resultDialog[Version]}"*.deb >/dev/null 2>&1; then
        get_deb_from_url \
            "${tmpInstallDeb}" \
            "${resultDialog[Version]}" \
            1 \
            "${resultDialog[Login]}" \
            "${resultDialog[Password]}"

        unzip "${tmpInstallDeb}/*.zip" -d "${tmpInstallDeb}"
    fi

    if [ -n "${resultDialog[PassPhrase]}" ]; then
        for debFile in "${tmpInstallDeb}"/*"${resultDialog[Version]}"*.deb; do

            [ -e "${debFile}" ] || continue
            [[ "$debFile" =~ "-nls_" ]] && continue

            send_deb_to_aptly \
                "${debFile}" \
                "${resultDialog[AptlyURL]}" \
                "${resultDialog[RepoName]}" \
                "${resultDialog[DistributionName]}" \
                "${resultDialog[PassPhrase]}" \

        done
    fi

    rm -r "${tmpInstallDeb}"

fi