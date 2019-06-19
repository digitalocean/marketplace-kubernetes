#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

FLUENT_BIT_CHART_VERSION="2.0.5"
FLUENTD_CHART_VERSION="1.10.0"

cp -r "$ROOT_DIR"/charts/fluent-bit/"$FLUENT_BIT_CHART_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/charts/fluentd/"$FLUENTD_CHART_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/2 $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$FLUENT_BIT_CHART_VERSION" -type d -name tests -print0 | xargs -0 rm -rf
find "$FLUENTD_CHART_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/2/yaml
mkdir -p "$ROOT_DIR"/stacks/2/yaml

# render fluent-bit
helm template \
  --name fluent-bit \
  --namespace logging \
  --values 2/values/fluent-bit.yaml \
  "$FLUENT_BIT_CHART_VERSION" > "$ROOT_DIR"/stacks/2/yaml/fluent-bit.yaml

# render fluentd
helm template \
  --name fluentd \
  --namespace logging \
  --values 2/values/fluentd.yaml \
  "$FLUENTD_CHART_VERSION" > "$ROOT_DIR"/stacks/2/yaml/fluentd.yaml