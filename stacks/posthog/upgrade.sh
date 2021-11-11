#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add posthog https://posthog.github.io/charts-clickhouse/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="posthog"
CHART="posthog/posthog"
NAMESPACE="posthog"


# use github hosted master version of values.yml
values="https://raw.githubusercontent.com/PostHog/charts-clickhouse/main/do_1_click_values.yaml"

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
