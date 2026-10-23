#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add plane https://helm.plane.so/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="plane-app"
CHART="plane/plane-enterprise"
NAMESPACE="plane"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/plane/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/plane/values.yml"
fi

# --reuse-values keeps everything deploy.sh set previously (the per-install
# secrets, above all) for any key not re-specified below. This script never
# generates secrets itself -- only deploy.sh does, and only on first install.
set -- --namespace "$NAMESPACE" --values "$values" --reuse-values

# DOMAIN_NAME: deploy.sh auto-derives a working <traefik-lb-ip>.sslip.io
# domain on first install. Once you have a real domain, point its DNS at
# that same LoadBalancer IP and switch to it here, e.g.:
#   DOMAIN_NAME=plane.example.com ./upgrade.sh
if [ -n "${DOMAIN_NAME}" ]; then
  set -- "$@" --set license.licenseDomain="$DOMAIN_NAME"
fi

# PLANE_VERSION: the Plane application version (distinct from the Helm
# chart version, which this script does not pin -- see deploy.sh).
if [ -n "${PLANE_VERSION}" ]; then
  set -- "$@" --set planeVersion="$PLANE_VERSION"
fi

helm upgrade "$STACK" "$CHART" "$@"
