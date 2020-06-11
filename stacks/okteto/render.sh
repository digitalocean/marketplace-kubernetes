#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="0.5.1"

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/okteto/yaml
mkdir -p "$ROOT_DIR"/stacks/okteto/yaml


# render YAML
helm template "do" "${ROOT_DIR}/src/okteto/${SRC_VERSION}" --namespace okteto --values values.yaml > "$ROOT_DIR"/stacks/okteto/yaml/okteto.yaml

cp "$ROOT_DIR"/src/okteto/"$SRC_VERSION"/crds.yaml "$ROOT_DIR"/stacks/okteto/yaml/crds.yaml
