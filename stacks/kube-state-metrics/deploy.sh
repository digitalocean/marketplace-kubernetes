#!/bin/sh

set -e

# declare variables
CHART_VERSION="2.8.4"
NAMESPACE="kube-system"

# deploy kube-state-metrics
helm install stable/kube-state-metrics -g --version "$CHART_VERSION" -n "$NAMESPACE" --values=values.yaml --wait

