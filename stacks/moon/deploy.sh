#!/bin/sh

set -e

# create moon namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: moon
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=moon

# deploy moon
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/moon/yaml/moon.yaml

# ensure services are running
kubectl rollout status -w deployment/moon
