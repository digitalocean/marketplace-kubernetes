#!/bin/sh

set -e

# Create clusterrolebbinding for default sa
kubectl create clusterrolebinding add-on-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=default:default

# Install Gluu cloud native edition, KubeDB
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gluu/yaml/gluu.yaml
# Wait for main services to run
kubectl -n gluu wait --for=condition=available --timeout=900s deploy/gluu-oxauth
kubectl -n gluu wait --for=condition=available --timeout=300s deploy/gluu-oxd-server
# Install Gluu Gateway UI
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gluu/yaml/gluu-gateway.yaml

