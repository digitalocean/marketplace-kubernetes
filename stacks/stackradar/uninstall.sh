#!/bin/sh

set -eu

################################################################################
# chart
################################################################################
STACK="stackradar"
NAMESPACE="stackradar"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

# Two objects carry `helm.sh/resource-policy: keep` and survive on purpose:
# the bundled Postgres volume (PersistentVolumeClaim
# data-stackradar-postgresql-0), so an uninstall is not a data loss, and the
# `stackradar` ServiceAccount, so workload-identity annotations put on it are
# not lost across a reinstall. Nothing cluster-scoped is left behind. To
# remove both and the namespace as well:
#   kubectl delete namespace stackradar
