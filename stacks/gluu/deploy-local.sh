#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# Create clusterrolebbinding for default sa
kubectl create clusterrolebinding gluu-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=default:default

# Install Gluu cloud native edition
kubectl -n default apply -f "$ROOT_DIR"/stacks/gluu/yaml/gluu.yaml
