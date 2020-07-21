#!/bin/sh

set -e

if ! [ -x "$(command -v uname)" ]; then
  echo 'Error: uname command is not available.' >&2
  exit 1
fi

if [ -z "${HELM_REPO_NAME}" ]; then
  echo "HELM_REPO_NAME variable not defined."
  exit 1
fi

if [ -z "${HELM_REPO_URL}" ]; then
  echo "HELM_REPO_URL variable not defined."
  exit 1
fi

if [ -z "${STACK_NAME}" ]; then
  echo "STACK_NAME variable not defined."
  exit 1
fi

if [ -z "${CHART_NAME}" ]; then
  echo "CHART_NAME variable not defined."
  exit 1
fi

if [ -z "${CHART_VERSION}" ]; then
  echo "CHART_VERSION variable not defined."
  exit 1
fi

if [ -z "${NAMESPACE}" ]; then
  echo "NAMESPACE variable not defined."
  exit 1
fi

ROOT_DIR=$(git rev-parse --show-toplevel)

# create stack directory
NEW_DIR_PATH="$ROOT_DIR/stacks/$STACK_NAME"
mkdir -p "$NEW_DIR_PATH"

# copy files
cp -r "$ROOT_DIR"/utils/stack-templates/* "$NEW_DIR_PATH"

UNAME=$(uname)

for file in "$NEW_DIR_PATH"/*
do
  if [ "$UNAME" = "Darwin" ] ; then
    sed -i '' "s,{{HELM_REPO_NAME}},$HELM_REPO_NAME,g" "$file"
    sed -i '' "s,{{HELM_REPO_URL}},$HELM_REPO_URL,g" "$file"
    sed -i '' "s,{{STACK_NAME}},$STACK_NAME,g" "$file"
    sed -i '' "s,{{CHART_NAME}},$CHART_NAME,g" "$file"
    sed -i '' "s,{{CHART_VERSION}},$CHART_VERSION,g" "$file"
    sed -i '' "s,{{NAMESPACE}},$NAMESPACE,g" "$file"
  else
    sed -i "s,{{HELM_REPO_NAME}},$HELM_REPO_NAME,g" "$file"
    sed -i "s,{{HELM_REPO_URL}},$HELM_REPO_URL,g" "$file"
    sed -i "s,{{STACK_NAME}},$STACK_NAME,g" "$file"
    sed -i "s,{{CHART_NAME}},$CHART_NAME,g" "$file"
    sed -i "s,{{CHART_VERSION}},$CHART_VERSION,g" "$file"
    sed -i "s,{{NAMESPACE}},$NAMESPACE,g" "$file"
  fi
done
