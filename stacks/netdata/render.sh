#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="1.1.13"

cp -r "$ROOT_DIR"/src/netdata/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/netdata $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/netdata/yaml
mkdir -p "$ROOT_DIR"/stacks/netdata/yaml

# render mginx-ingress
helm template \
  --name netdata \
  --namespace netdata \
  --values $SRC_VERSION/values.yaml \
  --values "$ROOT_DIR"/stacks/netdata/values.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/netdata/yaml/netdata.yaml
