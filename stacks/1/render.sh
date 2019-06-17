#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

GRAFANA_CHART_VERSION="3.4.2"
PROMETHEUS_CHART_VERSION="8.11.4"

cp -r "$ROOT_DIR"/packages/grafana/charts/"$GRAFANA_CHART_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/packages/prometheus/charts/"$PROMETHEUS_CHART_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/1 $BUILD_DIR

cd $BUILD_DIR

# Remove grafana test templates
rm -rf "$GRAFANA_CHART_VERSION"/templates/tests

# Create YAML directory
mkdir -p "$ROOT_DIR"/stacks/1/yaml

# render grafana
helm template \
  --name grafana \
  --namespace grafana \
  --values 1/values/grafana.yaml \
  "$GRAFANA_CHART_VERSION" > "$ROOT_DIR"/stacks/1/yaml/grafana.yaml

# render prometheus
helm template \
  --name prometheus \
  --namespace prometheus \
  --values 1/values/prometheus.yaml \
  "$PROMETHEUS_CHART_VERSION" > "$ROOT_DIR"/stacks/1/yaml/prometheus.yaml
