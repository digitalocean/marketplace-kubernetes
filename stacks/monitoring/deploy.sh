#!/bin/sh

set -e

sh -c "curl --location --silent --show-error https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/metrics-server/deploy.sh | sh"
sh -c "curl --location --silent --show-error https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/prometheus-operator/deploy.sh | sh"
