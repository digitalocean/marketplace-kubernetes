#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="frappe-operator"
NAMESPACE="frappe-operator-system"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

################################################################################
# Database resources and CRDs are preserved
################################################################################
# Uninstalling the operator Helm release removes the controller and bundled subcharts.
# Site databases (MariaDB CRs, external DBs, or optional PostgreSQL clusters)
# and persistent volumes are preserved so tenant data is never destroyed.
if kubectl get deployment stackgres-operator -n stackgres >/dev/null 2>&1; then
  echo ""
  echo "Note: StackGres PostgreSQL Operator is running in namespace 'stackgres'."
  echo "It was left in place to protect any active database clusters."
fi
