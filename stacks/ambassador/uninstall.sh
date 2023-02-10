#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="edge-stack"
NAMESPACE="ambassador"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

kubectl delete -f https://app.getambassador.io/yaml/edge-stack/2.3.0/aes-crds.yaml
