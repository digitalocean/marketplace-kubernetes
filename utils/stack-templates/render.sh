#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="1.0.0"

cp -r "$ROOT_DIR"/src/{{STACK_NAME}}/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/{{STACK_NAME}} $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/{{STACK_NAME}}/yaml
mkdir -p "$ROOT_DIR"/stacks/{{STACK_NAME}}/yaml

# render mginx-ingress
helm template \
  --name {{STACK_NAME}} \
  --namespace {{STACK_NAME}} \
  --values {{STACK_NAME}}/values/{{STACK_NAME}}.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/{{STACK_NAME}}/yaml/{{STACK_NAME}}.yaml
