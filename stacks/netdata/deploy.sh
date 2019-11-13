#!/bin/sh

set -e

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: netdata
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=netdata

# deploy netdata
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/netdata/yaml/netdata.yaml

# ensure services are running
kubectl rollout status -w statefulset/netdata-master
kubectl rollout status -w daemonset/netdata-slave

