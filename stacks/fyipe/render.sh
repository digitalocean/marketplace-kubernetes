#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="3.0.0"

cp -r "$ROOT_DIR"/src/fyipe/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/fyipe $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/fyipe/yaml
mkdir -p "$ROOT_DIR"/stacks/fyipe/yaml

# render YAML
helm template \
  fyipe \
  --namespace fyipe \
  --values "$ROOT_DIR"/src/fyipe/$SRC_VERSION/values.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/fyipe/yaml/fyipe.yaml
