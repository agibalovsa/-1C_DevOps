#!/usr/bin/env bash
set -e

if [ -z "$GITLAB_PRIVATE_TOKEN" ]; then
  echo "GITLAB_PRIVATE_TOKEN not set"
  echo "Please set the GitLab Private Token as GITLAB_PRIVATE_TOKEN"
  exit 1
fi

# Extract the host where the server is running, and add the URL to the APIs
[[ $CI_PROJECT_URL =~ ^https?://[^/]+ ]] && HOST="${BASH_REMATCH[0]}/api/v4/projects/"

# Default branch
TARGET_BRANCH=$(curl --silent "${HOST}${CI_PROJECT_ID}" --header "PRIVATE-TOKEN:${GITLAB_PRIVATE_TOKEN}" | jq --raw-output '.default_branch');

# MR options
BODY="{
    \"id\": ${CI_PROJECT_ID},
    \"source_branch\": \"${CI_COMMIT_REF_NAME}\",
    \"target_branch\": \"${TARGET_BRANCH}\",
    \"remove_source_branch\": true,
    \"title\": \"MR: ${CI_COMMIT_REF_NAME}\",
    \"assignee_id\":\"${GITLAB_USER_ID}\"
}";

# Require a list of all the merge request and take a look if there is already
# one with the same source branch
LIST_MR=$(curl --silent "${HOST}${CI_PROJECT_ID}/merge_requests?state=opened" --header "PRIVATE-TOKEN:${GITLAB_PRIVATE_TOKEN}");
COUNT_BRANCHES=$(echo "${LIST_MR}" | grep -o "\"source_branch\":\"${CI_COMMIT_REF_NAME}\"" | wc -l);

# No MR found, let's create a new one
if [ "${COUNT_BRANCHES}" -eq "0" ]; then
    curl -X POST "${HOST}${CI_PROJECT_ID}/merge_requests" \
        --header "PRIVATE-TOKEN:${GITLAB_PRIVATE_TOKEN}" \
        --header "Content-Type: application/json" \
        --data "${BODY}";
    echo "Opened a new merge request: WIP: ${CI_COMMIT_REF_NAME} and assigned to you";
    exit;
fi

echo "No new merge request opened";
