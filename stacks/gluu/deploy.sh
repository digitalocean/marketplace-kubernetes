#!/bin/sh

set -e

# Create clusterrolebbinding for default sa
kubectl create clusterrolebinding gluu-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=default:default

# Install Gluu cloud native edition
kubectl -n default apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gluu/yaml/gluu.yaml
