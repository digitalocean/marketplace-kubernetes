#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

GLUU_VERSION="4.2"

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/gluu/yaml
mkdir -p "$ROOT_DIR"/stacks/gluu/yaml


cp "$ROOT_DIR"/src/gluu/"$GLUU_VERSION"/gluu.yaml "$ROOT_DIR"/stacks/gluu/yaml/gluu.yaml
