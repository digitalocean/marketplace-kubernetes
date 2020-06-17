#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# Create clusterrolebbinding for default sa
kubectl create clusterrolebinding gluu-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=default:default

# Install Gluu cloud native edition, KubeDB
kubectl -n default apply -f "$ROOT_DIR"/stacks/gluu/yaml/gluu.yaml

# Wait for Gluu CN installation job to finish
kubectl -n default wait --for=condition=complete --timeout=900s job/gluu-cloud-native-installer

# Wait for main services to run
kubectl -n gluu wait --for=condition=available --timeout=900s deploy/gluu-oxauth
kubectl -n gluu wait --for=condition=available --timeout=300s deploy/gluu-oxd-server

# Install Gluu Gateway UI
kubectl -n default apply -f "$ROOT_DIR"/stacks/gluu/yaml/gluu-gateway.yaml

# Wait for Gluu Gateway installation job to finish
kubectl -n default wait --for=condition=complete --timeout=900s job/gluu-cloud-native-installer-gluu-gateway
