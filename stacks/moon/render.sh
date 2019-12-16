#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="1.3.9"

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/moon/yaml
mkdir -p "$ROOT_DIR"/stacks/moon/yaml

cp "$ROOT_DIR"/src/moon/"$SRC_VERSION"/moon.yaml "$ROOT_DIR"/stacks/moon/yaml/moon.yaml
