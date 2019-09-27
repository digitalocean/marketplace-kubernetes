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

ROOT_DIR=$(git rev-parse --show-toplevel)

sh "$ROOT_DIR"/stacks/sharkahack/deploy-nginx-ingress.sh
sh "$ROOT_DIR"/stacks/metrics-server/deploy-local.sh
sh "$ROOT_DIR"/stacks/sharkahack-prometheus-operator/deploy-local.sh
sh "$ROOT_DIR"/stacks/sharkahack/shared.sh
