#!/bin/sh

set -e

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: storageos
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=storageos

# deploy storageos operator
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/storageos/yaml/storageos.yaml

# ensure operator is running
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  kubectl rollout status -w deployment/"$line"
done

# deploy storageos cluster
kubectl apply -f "$ROOT_DIR"/stacks/storageos/yaml/storageos-cluster.yaml

# ensure cluster is running
until kubectl -n kube-system get daemonset storageos-daemonset --no-headers -o go-template='{{.status.numberReady}}' | grep -q 1; do sleep 1; done
