#!/bin/sh

set -e

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: redskyops
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=redskyops

# deploy redskyops
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/redskyops/yaml/redskyops.yaml

# ensure services are running
kubectl rollout status deployment/redskyops-controller-manager
