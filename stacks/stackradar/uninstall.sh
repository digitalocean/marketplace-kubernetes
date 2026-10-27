#!/bin/sh

set -eu

################################################################################
# chart
################################################################################
STACK="stackradar"
NAMESPACE="stackradar"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

# Three objects survive on purpose, so an uninstall is not a data loss and a
# reinstall with deploy.sh opens the same database:
# - the bundled Postgres volume (PersistentVolumeClaim
#   data-stackradar-postgresql-0, `helm.sh/resource-policy: keep`);
# - the Secret stackradar-credentials, which deploy.sh created outside Helm
#   and which holds that volume's password and the other generated secrets;
# - the `stackradar` ServiceAccount (`helm.sh/resource-policy: keep`), so
#   workload-identity annotations put on it are not lost.
# Nothing cluster-scoped is left behind. To remove all three, data included:
#   kubectl delete namespace stackradar
