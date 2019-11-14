#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

METRICS_SERVER_VERSION="0.3.6"

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/metrics-server/yaml
mkdir -p "$ROOT_DIR"/stacks/metrics-server/yaml

# render metrics-server
cp -r "$ROOT_DIR"/src/metrics-server/"$METRICS_SERVER_VERSION"/ "$BUILD_DIR"
cp -r "$ROOT_DIR"/stacks/metrics-server/patch/ "$BUILD_DIR"
kubectl kustomize "$BUILD_DIR" > "$ROOT_DIR"/stacks/metrics-server/yaml/metrics-server.yaml
