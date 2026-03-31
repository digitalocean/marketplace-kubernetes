#!/bin/sh
set -e

################################################################################
# DigitalOcean Marketplace Kubernetes — Defensia Agent
# Deploys the Defensia security agent as a DaemonSet via Helm chart
################################################################################

STACK_NAME="defensia-agent"
CHART_VERSION="0.4.1"
NAMESPACE="defensia-system"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "${MP_KUBERNETES}" ]; then
  # Local/dev mode — use values file next to this script
  VALUES_FILE="${SCRIPT_DIR}/values.yml"
else
  # Marketplace mode — fetch values from GitHub
  VALUES_FILE="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK_NAME}/values.yml"
fi

helm upgrade "$STACK_NAME" oci://ghcr.io/defensia/charts/defensia-agent \
  --rollback-on-failure \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$VALUES_FILE" \
  --version "$CHART_VERSION"
