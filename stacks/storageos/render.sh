#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

SRC_VERSION="0.2.16"

cp -r "$ROOT_DIR"/src/storageos/"$SRC_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/storageos $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$SRC_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Remove cleanup template.  The cleanup resources use Helm hooks which won't be
# available.  Instead, the Jobs will get deployed immediately and error if kept.
rm -f "$SRC_VERSION/templates/cleanup.yaml"

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/storageos/yaml
mkdir -p "$ROOT_DIR"/stacks/storageos/yaml

# render storageos-operator, leaving out the cluster.
helm template \
  --name storageos \
  --namespace storageos \
  --values "$ROOT_DIR"/src/storageos/"$SRC_VERSION"/values.yaml \
  --values "$ROOT_DIR"/stacks/storageos/override.yaml \
  --set cluster.create=false \
  "$SRC_VERSION" > "$ROOT_DIR"/stacks/storageos/yaml/storageos-operator.yaml

# render the cluster separately.
helm template \
  --name storageos \
  --namespace storageos \
  --values "$ROOT_DIR"/src/storageos/"$SRC_VERSION"/values.yaml \
  --values "$ROOT_DIR"/stacks/storageos/override.yaml \
  "$SRC_VERSION" \
  -x templates/storageoscluster_cr.yaml \
  -x templates/psp.yaml > "$ROOT_DIR"/stacks/storageos/yaml/storageos-cluster.yaml

