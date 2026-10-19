#!/bin/sh

set -e

################################################################################
# prerequisites: Traefik for Simple Host alone (its own IngressClass, so a
# controller the cluster already runs is left alone), and cert-manager unless
# the cluster has it
################################################################################
TRAEFIK_VERSION="41.6.0"
CERT_MANAGER_VERSION="v1.21.2"

helm repo add traefik https://traefik.github.io/charts
helm repo add jetstack https://charts.jetstack.io
helm repo update > /dev/null

traefik_values=$(mktemp)
trap 'rm -f "$traefik_values"' EXIT
cat > "$traefik_values" <<'VALUES'
fullnameOverride: traefik
deployment:
  replicas: 2
podDisruptionBudget:
  enabled: true
  maxUnavailable: 1
ingressClass:
  enabled: true
  isDefaultClass: false
  name: simple-host
providers:
  kubernetesCRD:
    enabled: false
  kubernetesIngress:
    ingressClass: simple-host
    namespaces: ["simple-host"]
ports:
  web:
    http:
      redirections:
        entryPoint: {to: websecure, scheme: https, permanent: true}
    # The DigitalOcean load balancer sends PROXY protocol, so each visitor's
    # own address reaches Simple Host. Only from private addresses.
    proxyProtocol:
      trustedIPs: ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  websecure:
    # Uploads are up to 100 MiB (MAX_ARCHIVE_BYTES); Traefik has no body cap,
    # and five minutes covers a slow link.
    transport:
      respondingTimeouts: {readTimeout: 300s, writeTimeout: 300s, idleTimeout: 360s}
    proxyProtocol:
      trustedIPs: ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
service:
  annotations:
    service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol: "true"
VALUES

helm upgrade traefik traefik/traefik \
  --install \
  --create-namespace \
  --namespace simple-host-ingress \
  --version "$TRAEFIK_VERSION" \
  --skip-crds \
  --values "$traefik_values" \
  --wait \
  --timeout 10m

CERT_MANAGER_NAMESPACE=$(kubectl get deploy -A -l app.kubernetes.io/name=cert-manager,app.kubernetes.io/component=controller -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || true)
if [ -z "$CERT_MANAGER_NAMESPACE" ]; then
  CERT_MANAGER_NAMESPACE="cert-manager"
  helm upgrade cert-manager jetstack/cert-manager \
    --install \
    --create-namespace \
    --namespace "$CERT_MANAGER_NAMESPACE" \
    --version "$CERT_MANAGER_VERSION" \
    --set crds.enabled=true \
    --wait \
    --timeout 10m
fi

################################################################################
# chart
################################################################################
STACK="simple-host-enterprise"
CHART="${CHART:-oci://ghcr.io/vineetu/charts/simple-host-enterprise}"
CHART_VERSION="0.2.5"
NAMESPACE="simple-host"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/simple-host-enterprise/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/simple-host-enterprise/values.yml"
fi

# Every pod in the namespace must meet the restricted Pod Security profile.
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace "$NAMESPACE" --overwrite \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION" \
  --values "$values" \
  --set certificates.certManagerNamespace="$CERT_MANAGER_NAMESPACE" \
  --timeout 10m
