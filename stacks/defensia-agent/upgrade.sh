#!/bin/sh
set -e

################################################################################
# DigitalOcean Marketplace Kubernetes — Defensia Agent (Upgrade)
################################################################################

STACK_NAME="defensia-agent"
CHART_VERSION="0.4.1"
NAMESPACE="defensia-system"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "${MP_KUBERNETES}" ]; then
  VALUES_FILE="${SCRIPT_DIR}/values.yml"
else
  VALUES_FILE="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK_NAME}/values.yml"
fi

helm upgrade "$STACK_NAME" oci://ghcr.io/defensia/charts/defensia-agent \
  --rollback-on-failure \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$VALUES_FILE" \
  --version "$CHART_VERSION"
