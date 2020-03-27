#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="1.3.1"

cp -r "$ROOT_DIR"/src/op-scim-bridge/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/op-scim-bridge $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/op-scim-bridge/yaml
mkdir -p "$ROOT_DIR"/stacks/op-scim-bridge/yaml

# render mginx-ingress
helm template op-scim-bridge \
  --namespace op-scim-bridge \
  --values "$ROOT_DIR"/src/op-scim-bridge/"$SRC_VERSION"/values.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/op-scim-bridge/yaml/op-scim-bridge.yaml
