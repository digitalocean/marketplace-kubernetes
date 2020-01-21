#!/bin/sh

set -e

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
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/okteto/yaml/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/okteto/yaml/okteto.yaml

# generate a random password
PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)
kubectl label sa do-okteto-enterprise dev.okteto.com/token=$PASSWORD --overwrite

# ensure services are running
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  kubectl rollout status -w deployment/"$line"
done
