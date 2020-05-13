#!/bin/sh

set -e

STACK="helm3-test"
CHART="stable/kube-state-metrics"
CHART_VERSION="2.8.4"
NAMESPACE="kube-system"

if [ -z "$MP_KUBERNETES" ]
then 
#!/bin/sh
helm install "$CHART" \
  --create-namespace \
  --generate-name \
  --namespace "$NAMESPACE" \
  --values values.yaml \
  --version "$CHART_VERSION" \
  --wait
else
helm install "$CHART" \
  --create-namespace \
  --generate-name \
  --namespace "$NAMESPACE" \
  --values https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/"$STACK"/values.yaml \
  --version "$CHART_VERSION" \
  --wait
fi