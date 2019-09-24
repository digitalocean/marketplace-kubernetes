#!/bin/sh

set -e

if [ -z "${STACK_NAME}" ]; then
  echo "STACK_NAME variable not defined."
  exit 1
fi

ROOT_DIR=$(git rev-parse --show-toplevel)

# create stack directory
NEW_DIR_PATH="$ROOT_DIR/stacks/$STACK_NAME"
mkdir "$NEW_DIR_PATH"

# copy files
cp -r "$ROOT_DIR"/utils/stack-templates/* "$NEW_DIR_PATH"

UNAME=$(uname)

for file in "$NEW_DIR_PATH"/*
do
  if [ "$UNAME" = "Darwin" ] ; then
    sed -i '' "s/{{STACK_NAME}}/$STACK_NAME/g" "$file"
  else
    sed -i "s/{{STACK_NAME}}/$STACK_NAME/g" "$file"
  fi
done
