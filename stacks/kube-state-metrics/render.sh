#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

KUBE_STATE_METRICS_VERSION="1.8"

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/kube-state-metrics/yaml
mkdir -p "$ROOT_DIR"/stacks/kube-state-metrics/yaml

# render kube-state-metrics
cp -r "$ROOT_DIR"/src/kube-state-metrics/"$KUBE_STATE_METRICS_VERSION"/ "$BUILD_DIR"
kubectl kustomize "$BUILD_DIR" > "$ROOT_DIR"/stacks/kube-state-metrics/yaml/kube-state-metrics.yaml
