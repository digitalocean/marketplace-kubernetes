#!/bin/sh

set -e

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: {{STACK_NAME}}
EOF

# set kubectl namespace
kubectl config set-context --current --namespace={{STACK_NAME}}

# deploy {{STACK_NAME}}
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/{{STACK_NAME}}/yaml/{{STACK_NAME}}.yaml

# ensure services are running
kubectl rollout status deployment/{{STACK_NAME}}
