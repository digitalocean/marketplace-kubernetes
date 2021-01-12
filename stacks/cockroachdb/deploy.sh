#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add cockroachdb https://charts.cockroachdb.com/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="cockroachdb"
CHART="cockroachdb/cockroachdb"
CHART_VERSION="5.0.0"
NAMESPACE="cockroachdb"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/cockroachdb/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/cockroachdb/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --install \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"

sleep 30

for i in $(kubectl get csr | tail -n +2 | sed '1!G;h;$!d' | cut -d ' ' -f1 | grep cockroach); do kubectl certificate approve "$i"; sleep 10; done
