#!/usr/bin/env bash

send_deb_to_aptly ()
{
    local debPath="${1}"
    local aptlyApiURL="$2"
    local repoName="$3"
    local distributionName="$4"
    local passPhrase="$5"

    local fileName
    fileName=$(basename "${debPath}")
    local uploadDir="upload_pool"

    curl --fail-with-body -w "\n" -X POST \
        -F "file=@${debPath}" \
        "${aptlyApiURL}/api/files/${uploadDir}"

    curl --fail-with-body -w "\n" -X POST \
        "${aptlyApiURL}/api/repos/${repoName}/file/${uploadDir}/${fileName}?forceReplace=1&move=1"

    curl --fail-with-body -w "\n" -X PUT \
        -H "Content-Type: application/json" \
        -d "{
            \"ForceOverwrite\": true,
            \"Signing\": {
                \"Batch\": true,
                \"Passphrase\": \"${passPhrase}\"
            }
        }" \
        "${aptlyApiURL}/api/publish/_/${distributionName}"

}