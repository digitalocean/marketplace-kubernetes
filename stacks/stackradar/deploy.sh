#!/bin/sh

set -eu

################################################################################
# chart
################################################################################
STACK="stackradar"
CHART="oci://ghcr.io/lockdep/helm-charts/stackradar"
CHART_VERSION="0.2.2"
NAMESPACE="stackradar"

if [ -z "${MP_KUBERNETES:-}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/stackradar/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/stackradar/values.yml"
fi

################################################################################
# secrets
#
# The chart ships public fixture values for its secrets and never generates
# any (a generated value would change on every GitOps render). A 1-Click
# install is not a GitOps render, so generate them here, once, into a Secret
# that Helm does not own. `helm uninstall` therefore leaves it in place next
# to the kept Postgres volume, and a reinstall finds the same database
# password, the same `apiKeyEncryptionKey` (stored scanner keys stay
# readable) and the same scanner credential. `kubectl delete namespace
# stackradar` removes the volume and this Secret together.
################################################################################
SECRET="stackradar-credentials"
PVC="data-stackradar-postgresql-0"

random_hex() {
  head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n'
}

random_uuid() {
  if [ -r /proc/sys/kernel/random/uuid ]; then
    cat /proc/sys/kernel/random/uuid
  else
    h=$(random_hex)
    printf '%s-%s-4%s-a%s-%s\n' \
      "$(echo "$h" | cut -c1-8)" \
      "$(echo "$h" | cut -c9-12)" \
      "$(echo "$h" | cut -c13-15)" \
      "$(echo "$h" | cut -c16-18)" \
      "$(echo "$h" | cut -c19-30)"
  fi
}

if ! kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
  kubectl create namespace "$NAMESPACE"
fi

if ! kubectl get secret "$SECRET" --namespace "$NAMESPACE" > /dev/null 2>&1; then
  if kubectl get pvc "$PVC" --namespace "$NAMESPACE" > /dev/null 2>&1; then
    echo "error: the PostgreSQL volume $PVC exists but the Secret $SECRET" >&2
    echo "holding its password does not, so a new password could not open it." >&2
    echo "Restore the Secret, or delete the volume to start with an empty" >&2
    echo "database: kubectl delete pvc $PVC -n $NAMESPACE" >&2
    exit 1
  fi
  kubectl create secret generic "$SECRET" \
    --namespace "$NAMESPACE" \
    --from-literal="postgres-password=$(random_hex)" \
    --from-literal="internal-service-key=$(random_hex)" \
    --from-literal="api-key-encryption-key=$(random_hex)" \
    --from-literal="auth-secret=$(random_hex)" \
    --from-literal="admin-password=$(random_hex | cut -c1-24)" \
    --from-literal="cluster-id=$(random_uuid)" \
    --from-literal="api-key=$(random_hex)"
  kubectl label secret "$SECRET" --namespace "$NAMESPACE" \
    app.kubernetes.io/part-of=stackradar
fi

# Re-running deploy.sh on an existing release keeps any values set since.
set --
if helm status "$STACK" --namespace "$NAMESPACE" > /dev/null 2>&1; then
  set -- --reuse-values
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --timeout 15m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --set "postgresql.auth.existingSecret.name=$SECRET" \
  --set "postgresql.auth.existingSecret.passwordKey=postgres-password" \
  --set "secrets.existingSecret.name=$SECRET" \
  --set "scanner.stackradar.existingSecret=$SECRET" \
  "$@"
