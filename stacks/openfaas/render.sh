#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="5.2.2"

cp -r "$ROOT_DIR"/src/openfaas/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/openfaas $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/openfaas/yaml
mkdir -p "$ROOT_DIR"/stacks/openfaas/yaml

# render openfaas
helm template \
  --name openfaas \
  --namespace openfaas \
  --values "$ROOT_DIR"/src/openfaas/5.2.2/values.yaml \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/openfaas/yaml/openfaas.yaml
