#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="v0.2.0"

cp -r "$ROOT_DIR"/src/ambassador-operator/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/ambassador-operator $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/ambassador-operator/yaml
mkdir -p "$ROOT_DIR"/stacks/ambassador-operator/yaml

# render YAML
helm template ambassador-operator \
  --namespace ambassador-operator \
  --values ambassador-operator/yaml/ambassador-operator.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/ambassador-operator/yaml/ambassador-operator.yaml
