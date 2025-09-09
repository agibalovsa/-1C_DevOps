#!/usr/bin/env bash

set -Eeo pipefail

create_mr() {

    if [ -z "$GITLAB_PRIVATE_TOKEN" ]; then
        echo "GITLAB_PRIVATE_TOKEN not set"
        echo "Please set the GitLab Private Token as GITLAB_PRIVATE_TOKEN"
    fi

    # Default branch
    TARGET_BRANCH=$(curl --silent "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}" --header "PRIVATE-TOKEN:${GITLAB_PRIVATE_TOKEN}" | jq --raw-output '.default_branch');

    echo "Target branch: \"${TARGET_BRANCH}\""

    # MR options
    BODY="{
        \"id\": ${CI_PROJECT_ID},
        \"source_branch\": \"${CI_COMMIT_REF_NAME}\",
        \"target_branch\": \"${TARGET_BRANCH}\",
        \"remove_source_branch\": true,
        \"title\": \"MR: ${CI_COMMIT_REF_NAME}\",
        \"assignee_id\": \"${GITLAB_USER_ID}\"
    }";

    # Require a list of all the merge request and take a look if there is already
    # one with the same source branch
    LIST_MR=$(curl --silent "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/merge_requests?state=opened" --header "PRIVATE-TOKEN:${GITLAB_PRIVATE_TOKEN}");
    COUNT_MR=$(echo "${LIST_MR}" | (grep -o "\"source_branch\":\"${CI_COMMIT_REF_NAME}\"" || true) | wc -l);
    
    echo "Current MR (${CI_COMMIT_REF_NAME} - ${TARGET_BRANCH}): ${COUNT_MR}"

    # No MR found, let's create a new one
    if [ "${COUNT_MR}" -eq "0" ]; then
        curl -X POST "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/merge_requests" \
            --header "PRIVATE-TOKEN:${GITLAB_PRIVATE_TOKEN}" \
            --header "Content-Type: application/json" \
            --data "${BODY}";
        echo "Opened a new merge request: WIP: ${CI_COMMIT_REF_NAME} and assigned to you";
    else
        echo "No new merge request opened";
    fi

}

if [ "$1" == "sh" ]; then
    exec sh
elif [ "$1" == "bash" ]; then
    exec /bin/bash
else
    if [ "$1" = "create_mr" ]; then
        create_mr
    else
        exec /bin/bash
    fi;
fi

exit 0