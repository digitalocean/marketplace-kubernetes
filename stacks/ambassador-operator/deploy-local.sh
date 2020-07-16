#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ambassador-operator
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=ambassador-operator

# deploy ambassador-operator
kubectl apply -f https://github.com/datawire/ambassador-operator/releases/latest/download/ambassador-operator-crds.yaml
kubectl apply -f "$ROOT_DIR"/stacks/ambassador-operator/yaml/ambassador-operator.yaml

# ensure services are running
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  kubectl rollout status -w deployment/"$line"
done
