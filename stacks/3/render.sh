#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

METRICS_SERVER_VERSION="0.3.3"
METRICS_SERVER_DEPLOYMENT="metrics-server-deployment.yaml"

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/3/yaml
mkdir -p "$ROOT_DIR"/stacks/3/yaml

# Copy yaml files.
cp -r "$ROOT_DIR"/packages/metrics-server/"$METRICS_SERVER_VERSION"/ "$ROOT_DIR"/stacks/3/yaml

# render metrics-server-deployment yaml file
cp -r "$ROOT_DIR"/packages/metrics-server/"$METRICS_SERVER_VERSION"/"$METRICS_SERVER_DEPLOYMENT" "$BUILD_DIR"
cp -r "$ROOT_DIR"/stacks/3/patch/ "$BUILD_DIR"
kubectl kustomize "$BUILD_DIR" > "$ROOT_DIR"/stacks/3/yaml/"$METRICS_SERVER_DEPLOYMENT"
