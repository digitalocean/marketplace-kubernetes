#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add triliovault-operator http://charts.k8strilio.net/trilio-stable/k8s-triliovault-operator
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="triliovault-operator"
CHART="triliovault-operator/k8s-triliovault-operator"
CHART_VERSION="2.1.0"
NAMESPACE="tvk"
ROOT_DIR=$(git rev-parse --show-toplevel)

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  values="$ROOT_DIR/stacks/triliovault-operator/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/triliovault-operator/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"

TVM="$ROOT_DIR/stacks/$STACK/triliovault-manager.yaml"

kubectl apply -f "$TVM" --namespace "$NAMESPACE"

until (kubectl get pods -n "$NAMESPACE" -l "triliovault.trilio.io/owner=triliovault-manager" 2>/dev/null | grep Running); do sleep 3; done
sleep 5

