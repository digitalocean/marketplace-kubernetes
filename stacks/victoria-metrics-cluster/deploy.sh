#!/bin/sh

set -e


# Add VictoriaMetrics Helm repository

helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update > /dev/null

# Install the VM Operator from the Helm chart
helm install vmoperator vm/victoria-metrics-operator

# Install VictoriaMetrics Cluster with CRDs
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/victoria-metrics-cluster/yaml/vmcluster.yaml
kubectl get deployment -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
    kubectl rollout status -w --timeout=5m deployment/"${line}"
done

# Install VMAgent with CRDs
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/victoria-metrics-cluster/yaml/vmagent.yaml