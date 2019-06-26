#!/bin/sh

set -e

# create nginx-ingress namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: nginx-ingress
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=nginx-ingress

# deploy nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/nginx-ingress/yaml/nginx-ingress.yaml

# ensure services are running
kubectl rollout status deployment/nginx-ingress-controller
kubectl rollout status deployment/nginx-ingress-default-backend
