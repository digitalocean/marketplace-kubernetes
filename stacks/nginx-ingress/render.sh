#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

NGINX_INGRESS_CHART_VERSION="1.6.18"

cp -r "$ROOT_DIR"/src/nginx-ingress/"$NGINX_INGRESS_CHART_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/nginx-ingress $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$NGINX_INGRESS_CHART_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/nginx-ingress/yaml
mkdir -p "$ROOT_DIR"/stacks/nginx-ingress/yaml

# render mginx-ingress
helm template \
  --name nginx-ingress \
  --namespace nginx-ingress \
  --values nginx-ingress/values/nginx-ingress.yaml \
  "$NGINX_INGRESS_CHART_VERSION" > "$ROOT_DIR"/stacks/nginx-ingress/yaml/nginx-ingress.yaml
