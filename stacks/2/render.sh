#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)
STACK_DIR="$ROOT_DIR"/stacks/2

FLUENT_BIT_CHART_VERSION="2.0.6"
FLUENTD_CHART_VERSION="1.10.0"

mkdir "$BUILD_DIR"/fluent-bit
mkdir "$BUILD_DIR"/fluentd

cp -r "$ROOT_DIR/charts/fluent-bit/$FLUENT_BIT_CHART_VERSION" "$BUILD_DIR"/fluent-bit
cp -r "$ROOT_DIR/charts/fluentd/$FLUENTD_CHART_VERSION" "$BUILD_DIR"/fluentd

cd $BUILD_DIR

# Remove test templates
find "fluent-bit/$FLUENT_BIT_CHART_VERSION" -type d -name tests -print0 | xargs -0 rm -rf
find "fluentd/$FLUENTD_CHART_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/2/yaml
mkdir -p "$ROOT_DIR"/stacks/2/yaml

# render fluent-bit
helm template \
  --name fluent-bit \
  --namespace logging \
  --values "$STACK_DIR"/values/fluent-bit.yaml \
  "$BUILD_DIR/fluent-bit/$FLUENT_BIT_CHART_VERSION" > "$STACK_DIR"/yaml/fluent-bit.yaml

# render fluentd
helm template \
  --name fluentd \
  --namespace logging \
  --values "$STACK_DIR"/values/fluentd.yaml \
  "$BUILD_DIR/fluentd/$FLUENTD_CHART_VERSION" > "$STACK_DIR"/yaml/fluentd.yaml