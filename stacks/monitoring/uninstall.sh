#!/bin/sh

set -e

if [ -z "${MP_KUBERNETES}" ]; then
  ROOT_DIR=$(git rev-parse --show-toplevel)
  sh "$ROOT_DIR"/stacks/metrics-server/uninstall.sh
  sh "$ROOT_DIR"/stacks/kube-prometheus-stack/uninstall.sh
else
  sh -c "curl --location --silent --show-error https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/metrics-server/uninstall.sh | sh"
  sh -c "curl --location --silent --show-error https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kube-prometheus-stack/uninstall.sh | sh"
fi
