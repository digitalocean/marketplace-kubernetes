#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="1.6.0"

cp -r "$ROOT_DIR"/src/openebs/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/openebs $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/openebs/yaml
mkdir -p "$ROOT_DIR"/stacks/openebs/yaml

# render openebs-ingress
helm template \
  --name openebs \
  --namespace openebs \
  --values "$ROOT_DIR"/src/openebs/1.6.0/values.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/openebs/yaml/openebs.yaml
