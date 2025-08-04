#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="signoz"
NAMESPACE="signoz"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

kubectl -n "$NAMESPACE" patch \
  clickhouseinstallations.clickhouse.altinity.com/"$STACK"-clickhouse \
  -p '{"metadata":{"finalizers":[]}}' --type=merge

kubectl -n "$NAMESPACE" delete pvc -l app.kubernetes.io/instance="$STACK"

