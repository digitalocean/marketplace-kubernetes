#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="1.0.0"

cp -r "$ROOT_DIR"/src/vitess/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/vitess $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/vitess/yaml
mkdir -p "$ROOT_DIR"/stacks/vitess/yaml

# render YAML
helm template vitess \
  --namespace vitess \
  --values vitess/values/vitess.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/vitess/yaml/vitess.yaml
