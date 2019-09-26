#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

sh "$ROOT_DIR"/stacks/metrics-server/deploy-local.sh
sh "$ROOT_DIR"/stacks/sharkahack-prometheus-operator/deploy-local.sh
