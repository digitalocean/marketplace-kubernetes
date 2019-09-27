#!/bin/sh

set -e

DOMAIN=dohackafun.com

if [ -z "${DO_API_TOKEN}" ]; then
  echo "Error: DO_API_TOKEN not defined."
  exit 1
fi

if [ -z "${DOMAIN}" ]; then
  echo "Error: DOMAIN not defined."
  exit 1
fi

sh -c "curl --location --silent --show-error https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/sharkahack/deploy-nginx-ingress.sh | sh"
sh -c "curl --location --silent --show-error https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/metrics-server/deploy.sh | sh"
sh -c "curl --location --silent --show-error https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/sharkahack-prometheus-operator/deploy.sh | sh"
sh -c "curl --location --silent --show-error https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/sharkahack/shared.sh | sh"
