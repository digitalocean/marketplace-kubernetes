#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="0.1.2"

cp -r "$ROOT_DIR"/src/redskyops/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/redskyops $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/redskyops/yaml
mkdir -p "$ROOT_DIR"/stacks/redskyops/yaml

# render Red Sky Ops
helm template \
  --name redsky \
  --namespace redsky-system \
  --values redskyops/values/redskyops.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/redskyops/yaml/redskyops.yaml
