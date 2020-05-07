#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: vitess
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=vitess

# deploy vitess
kubectl apply -f "$ROOT_DIR"/stacks/vitess/yaml/vitess-operator.yaml
kubectl get deployment -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
    kubectl rollout status -w --timeout=5m deployment/"${line}"
done

kubectl apply -f "$ROOT_DIR"/stacks/vitess/yaml/example-cluster.yaml
# ensure services are running
kubectl get vitesskeyspace -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  # Since a vitesskeyspaces doesn't support conditions we have to poll the master status
  retry=0
  while [ "${retry}" -lt 30 ] && [ "$(kubectl get vitesskeyspace/"${line}" -o=jsonpath='{.status.shards..hasMaster}' | xargs -n1 echo | sort -u )" != "True" ]; do
    echo "Waiting for vitess keyspace ${line}"
    retry=$(( retry+1 ))
    sleep 10
  done
  echo "keyspace ${line} is ready."
done
