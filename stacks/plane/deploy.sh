#!/bin/sh

set -e

_rand() {
  LC_CTYPE=C LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "${1:-40}"
}

################################################################################
# repos
################################################################################
helm repo add traefik https://traefik.github.io/charts
helm repo add plane https://helm.plane.so/
helm repo update > /dev/null

################################################################################
# ingress controller
################################################################################
# plane-enterprise needs an ingress controller to be reachable at all -- it
# doesn't expose any service directly. DigitalOcean's Kubernetes 1-Click flow
# gives us no way to ask the user whether one is already installed, so this
# stack packages its own rather than treating it as a prerequisite.
# Idempotent: re-running this is a no-op if it's already at this version.
TRAEFIK_CHART_VERSION="37.4.0"

helm upgrade traefik traefik/traefik \
  --create-namespace \
  --install \
  --namespace traefik \
  --version "$TRAEFIK_CHART_VERSION" \
  --wait

################################################################################
# chart
################################################################################
STACK="plane-app"
CHART="plane/plane-enterprise"
CHART_VERSION="3.5.2"
NAMESPACE="plane"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/plane/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/plane/values.yml"
fi

# --reuse-values carries forward everything set below (secrets, domain, ...)
# on every later deploy.sh/upgrade.sh run that doesn't re-specify it. On a
# true first install there's nothing yet to reuse, so it's a no-op here.
set -- --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --timeout 15m0s \
  --wait-for-jobs \
  --reuse-values

FIRST_INSTALL=false
if ! helm status "$STACK" --namespace "$NAMESPACE" > /dev/null 2>&1; then
  FIRST_INSTALL=true
fi

################################################################################
# per-deployment secrets (first install only)
################################################################################
# Several defaults in the upstream chart -- the Django SECRET_KEY, the
# live-collaboration server secret, Silo's HMAC/AES keys, and the bundled
# Postgres/RabbitMQ/MinIO/OpenSearch credentials -- are fixed strings baked
# into the chart's own values.yaml and templates. Left as-is, every install
# of this stack across every DigitalOcean customer would share the exact
# same secrets, which are public right there in the chart source. Generate
# fresh ones on first install only: regenerating on top of an existing
# release would desync the app from credentials already written into
# Postgres/RabbitMQ/MinIO, and from sessions/tokens already signed with the
# old keys. --reuse-values above is what makes every later run keep these.
if [ "$FIRST_INSTALL" = true ]; then
  echo "First install for '$STACK' -- generating per-deployment secrets."
  set -- "$@" \
    --set env.secret_key="$(_rand 50)" \
    --set env.live_server_secret_key="$(_rand 40)" \
    --set env.pgdb_password="$(_rand 32)" \
    --set services.rabbitmq.default_password="$(_rand 32)" \
    --set services.minio.root_password="$(_rand 32)" \
    --set services.opensearch.password="$(_rand 32)" \
    --set env.silo_envs.hmac_secret_key="$(_rand 32)" \
    --set env.silo_envs.aes_secret_key="$(_rand 32)" \
    --set env.silo_envs.cursor_webhook_secret="$(_rand 32)"
fi

################################################################################
# domain (first install only, unless DOMAIN_NAME is already given)
################################################################################
# Most users install this from the DigitalOcean portal/Marketplace tab,
# which runs this script with no way to collect a domain first -- there's no
# form field for it, and no one is at a terminal to pass DOMAIN_NAME. But
# Plane's ingress only routes on hostname, so without one the app deploys
# healthy and nothing reaches it. Derive a working hostname from Traefik's
# own LoadBalancer IP via sslip.io's wildcard DNS ("plane.<ip>.sslip.io"
# always resolves back to <ip>, no DNS setup needed) -- the same pattern
# Knative/Epinio/Verrazzano use for exactly this bootstrap problem. Anyone
# who *does* have terminal access and a real domain can point it at the
# same IP and switch with:
#   DOMAIN_NAME=plane.example.com ./upgrade.sh
if [ -z "${DOMAIN_NAME}" ] && [ "$FIRST_INSTALL" = true ]; then
  echo "No DOMAIN_NAME given -- waiting for Traefik's LoadBalancer IP so Plane is reachable immediately (DigitalOcean Load Balancers can take a couple of minutes to provision)..."
  TRIES=0
  LB_IP=""
  while [ -z "$LB_IP" ] && [ "$TRIES" -lt 60 ]; do
    LB_IP=$(kubectl get svc traefik --namespace traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ -z "$LB_IP" ]; then
      TRIES=$((TRIES + 1))
      sleep 5
    fi
  done

  if [ -n "$LB_IP" ]; then
    DOMAIN_NAME="plane.${LB_IP}.sslip.io"
    echo "Using $DOMAIN_NAME (Traefik LoadBalancer IP: $LB_IP)."
  else
    echo "Timed out waiting for Traefik's LoadBalancer IP -- continuing without a domain. Plane will deploy healthy but won't be reachable until you set one: DOMAIN_NAME=<yours> ./upgrade.sh" >&2
  fi
fi

if [ -n "${DOMAIN_NAME}" ]; then
  set -- "$@" --set license.licenseDomain="$DOMAIN_NAME"
fi

# PLANE_VERSION: the Plane application version (distinct from CHART_VERSION
# above, which pins the Helm chart itself). Leave unset for the chart's own
# default.
if [ -n "${PLANE_VERSION}" ]; then
  set -- "$@" --set planeVersion="$PLANE_VERSION"
fi

helm upgrade "$STACK" "$CHART" "$@"
