#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="0.18.0"

cp -r "$ROOT_DIR"/src/loki/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/loki $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/loki/yaml
mkdir -p "$ROOT_DIR"/stacks/loki/yaml

# render loki 
helm template \
  --name loki \
  --namespace loki \
  --values "$SRC_VERSION"/values.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/loki/yaml/loki.yaml
