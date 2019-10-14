#!/bin/bash -l

## Standard ENV variables provided
# ---
# GITHUB_ACTION=The name of the action
# GITHUB_ACTOR=The name of the person or app that initiated the workflow
# GITHUB_EVENT_PATH=The path of the file with the complete webhook event payload.
# GITHUB_EVENT_NAME=The name of the event that triggered the workflow
# GITHUB_REPOSITORY=The owner/repository name
# GITHUB_BASE_REF=The branch of the base repository (eg the destination branch name for a PR)
# GITHUB_HEAD_REF=The branch of the head repository (eg the source branch name for a PR)
# GITHUB_REF=The branch or tag ref that triggered the workflow
# GITHUB_SHA=The commit SHA that triggered the workflow
# GITHUB_WORKFLOW=The name of the workflow that triggerdd the action
# GITHUB_WORKSPACE=The GitHub workspace directory path. The workspace directory contains a subdirectory with a copy of your repository if your workflow uses the actions/checkout action. If you don't use the actions/checkout action, the directory will be empty

# for logging and returning data back to the workflow,
# see https://help.github.com/en/articles/development-tools-for-github-actions#logging-commands
# echo ::set-output name={name}::{value}
# -- DONT FORGET TO SET OUTPUTS IN action.yml IF RETURNING OUTPUTS

# exit with a non-zero status to flag an error/failure

assume_role() {
  echo "Assuming role"
  CREDS=$(aws sts assume-role --role-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${AWS_ACCOUNT_ROLE}" --role-session-name ami-builder --output json)

  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export AWS_SESSION_TOKEN
  export AWS_DEFAULT_REGION=${AWS_REGION}

  AWS_ACCESS_KEY_ID=$(jq -r .Credentials.AccessKeyId <<< ${CREDS})
  AWS_SECRET_ACCESS_KEY=$(jq -r .Credentials.SecretAccessKey <<< ${CREDS})
  AWS_SESSION_TOKEN=$(jq -r .Credentials.SessionToken <<< ${CREDS})
}

if [ -z "${INPUT_TASK}" ]; then
  echo "Task not defined."
  exit 2
fi

if [ "${INPUT_TASK}" == "generate-account-ids" ]; then
  assume_role
  echo "fetching list of AWS Account IDs"
  aws_account_list=$(aws organizations list-accounts | jq '.Accounts[].Id' | sed s/\"//g  | paste -sd "," -)
  echo ${aws_account_list}
  echo ::set-output name=ids::"${aws_account_list}"
fi