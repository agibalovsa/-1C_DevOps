#!/usr/bin/env bash

# shellcheck disable=SC1091
. ../../scripts/dialog/dialog_lib.sh
. ../../scripts/1c/oc_lib.sh
. ../../scripts/aptly/aptly_lib.sh

declare -A resultDialog

if open_dialog "download-form.yml" resultDialog; then

    tmpInstallDeb="/tmp/install_deb"

    get_deb_from_url \
        "${tmpInstallDeb}" \
        "${resultDialog[Version]}" \
        1 \
        "${resultDialog[Login]}" \
        "${resultDialog[Password]}"

    unzip "${tmpInstallDeb}/*.zip" -d "${tmpInstallDeb}"

    if [ -n "${resultDialog[PassPhrase]}" ]; then
        for debFile in "${tmpInstallDeb}"/*.deb; do

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