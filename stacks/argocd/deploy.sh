#!/bin/sh

set -e

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=argocd

# deploy argocd
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/src/argocd/1.2.5/argocd.yaml

# add the DigitalOcean LBaaS LoadBalancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'


# ensure services are running
kubectl rollout status deployment/argocd
