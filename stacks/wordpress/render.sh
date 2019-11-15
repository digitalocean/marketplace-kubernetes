#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="8.0.0"

cp -r "$ROOT_DIR"/src/wordpress/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/wordpress $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/wordpress/yaml
mkdir -p "$ROOT_DIR"/stacks/wordpress/yaml

# render mginx-ingress
helm template \
  --name wordpress \
  --namespace wordpress \
  --values "$ROOT_DIR"/src/wordpress/8.0.0/values.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/wordpress/yaml/wordpress.yaml
