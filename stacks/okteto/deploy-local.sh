#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: okteto
  labels:
    certmanager.k8s.io/disable-validation: "true"
    app.kubernetes.io/name: "okteto"
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=okteto

# deploy okteto
kubectl apply -f "$ROOT_DIR"/stacks/okteto/yaml/crds.yaml
kubectl apply -f "$ROOT_DIR"/stacks/okteto/yaml/okteto.yaml

# generate a random password
PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)
kubectl label sa do-okteto-enterprise dev.okteto.com/token=$PASSWORD --overwrite

# ensure services are running
kubectl rollout status -w deployment/do-cainjector
kubectl rollout status -w deployment/do-cert-manager
kubectl rollout status -w deployment/do-nginx-ingress-controller
kubectl rollout status -w deployment/do-nginx-ingress-default-backend
kubectl rollout status -w deployment/do-okteto-enterprise-api
kubectl rollout status -w deployment/do-okteto-enterprise-frontend
kubectl rollout status -w deployment/do-okteto-enterprise-mutation-webhook
kubectl rollout status -w deployment/do-webhook