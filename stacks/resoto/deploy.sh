#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add someengineering https://helm.some.engineering
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="resoto"
CHART="someengineering/resoto"
NAMESPACE="resoto"
values=values.yaml

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --timeout 20m
