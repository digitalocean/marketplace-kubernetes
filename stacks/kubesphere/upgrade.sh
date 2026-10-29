#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kubesphere"
NAMESPACE="kubesphere-system"

helm status "$STACK" --namespace "$NAMESPACE" > /dev/null

LEGACY_INSTALLER=$(kubectl get deployment ks-installer \
    --namespace "$NAMESPACE" --ignore-not-found --output=name)
if [ -n "$LEGACY_INSTALLER" ]; then
    printf '%s\n' "Legacy ks-installer detected. Migrate KubeSphere 3.x before using this upgrade script." >&2
    exit 1
fi

exec sh "$(dirname "$0")/deploy.sh"
