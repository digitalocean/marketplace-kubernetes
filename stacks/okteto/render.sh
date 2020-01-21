#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="0.3.0"

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/okteto/yaml
mkdir -p "$ROOT_DIR"/stacks/okteto/yaml

cp "$ROOT_DIR"/src/okteto/"$SRC_VERSION"/okteto.yaml "$ROOT_DIR"/stacks/okteto/yaml/okteto.yaml
cp "$ROOT_DIR"/src/okteto/"$SRC_VERSION"/crds.yaml "$ROOT_DIR"/stacks/okteto/yaml/crds.yaml
