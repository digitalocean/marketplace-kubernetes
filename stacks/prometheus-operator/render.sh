#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

PROMETHEUS_OPERATOR_CHART_VERSION="8.2.0"

cp -r "$ROOT_DIR"/src/prometheus-operator/"$PROMETHEUS_OPERATOR_CHART_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/prometheus-operator $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$PROMETHEUS_OPERATOR_CHART_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/prometheus-operator/yaml
mkdir -p "$ROOT_DIR"/stacks/prometheus-operator/yaml

# render prometheus-operator
helm template \
  --name prometheus-operator \
  --namespace prometheus-operator \
  --values prometheus-operator/values/prometheus-operator.yaml \
  "$PROMETHEUS_OPERATOR_CHART_VERSION" > "$ROOT_DIR"/stacks/prometheus-operator/yaml/prometheus-operator.yaml
