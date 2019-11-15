#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: wordpress
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=wordpress

# deploy wordpress
kubectl apply -f "$ROOT_DIR"/stacks/wordpress/yaml/wordpress.yaml

# ensure services are running
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  kubectl rollout status -w deployment/"$line"
done
