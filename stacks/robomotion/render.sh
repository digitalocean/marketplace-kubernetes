#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="1.0.5"

cp -r "$ROOT_DIR"/src/robomotion/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/robomotion $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/robomotion/yaml
mkdir -p "$ROOT_DIR"/stacks/robomotion/yaml

helm template \
 --name robomotion \
 --namespace robomotion-system \
 --values "$ROOT_DIR"/src/robomotion/"$SRC_VERSION"/values.yaml \
 "$SRC_VERSION" > "$ROOT_DIR"/stacks/robomotion/yaml/robomotion.yaml
