#!/bin/sh

set -e


################################################################################
# repo
################################################################################
helm repo add frappe-operator https://vyogotech.github.io/frappe-operator/helm-repo
helm repo update > /dev/null

################################################################################
# chart
################################################################################
# Bundles MariaDB Operator, KEDA, NGINX Ingress Controller, and OpenEBS NFS
STACK="frappe-operator"
CHART="frappe-operator/frappe-operator"
CHART_VERSION="5.2.6"
NAMESPACE="frappe-operator-system"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/frappe-operator/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/frappe-operator/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
