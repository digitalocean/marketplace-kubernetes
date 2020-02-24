#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="0.19.8"

cp -r "$ROOT_DIR"/src/jaeger/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/jaeger $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/jaeger/yaml
mkdir -p "$ROOT_DIR"/stacks/jaeger/yaml

# render mginx-ingress
helm template \
  --name jaeger \
  --namespace jaeger \
  --values "$SRC_VERSION"/values.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/jaeger/yaml/jaeger.yaml
