#!/bin/sh

set -e

helm uninstall -n prometheus-operator prometheus-operator || echo -n 'prometheus-operator not installed'

kubectl delete ns prometheus-operator --ignore-not-found

################################################################################
# repo
################################################################################
# helm repo add stable https://kubernetes-charts.storage.googleapis.com
# helm repo update

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update

################################################################################
# chart
################################################################################
STACK="prometheus-operator"
# CHART="stable/prometheus-operator"
CHART="prometheus-community/kube-prometheus-stack"
# CHART_VERSION="9.3.0"
CHART_VERSION="11.0.2"
NAMESPACE="prometheus-operator"

# if [ -z "${MP_KUBERNETES}" ]; then
#   # use local version of values.yml
#   ROOT_DIR=$(git rev-parse --show-toplevel)
#   values="$ROOT_DIR/stacks/prometheus-operator/values.yml"
# else
#   # use github hosted master version of values.yml
#   values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/prometheus-operator/values.yml"
# fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --values "values.yaml"  \


# -----
# prometheus-operator
# grafana login ID: admin, password: prom-operator


# check if metrics-server is already installed
CHECK=$(kubectl get svc metrics-server -n kube-system --ignore-not-found)
if [ "$CHECK" = "" ]
then
  echo "metrics-server not found"
else
  echo "metrics-server found, exiting"
  exit 0
fi

################################################################################
# repo
################################################################################
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

################################################################################
# chart
################################################################################
STACK="metrics-server"
CHART="bitnami/metrics-server"
CHART_VERSION="4.3.0"
NAMESPACE="kube-system"

# if [ -z "${MP_KUBERNETES}" ]; then
#   # use local version of values.yml
#   ROOT_DIR=$(git rev-parse --show-toplevel)
#   values="$ROOT_DIR/stacks/metrics-server/values.yml"
# else
#   # use github hosted master version of values.yml
#   values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/metrics-server/values.yml"
# fi

helm upgrade --install "$STACK" "$CHART" --atomic --namespace "$NAMESPACE" --version "$CHART_VERSION" -f metrics-server-values.yaml

# # kube-prometheus-stack
# # https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack#configuration