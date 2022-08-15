#!/bin/sh

set -e

STACK="epinio"
CHART="epinio/epinio"
CHART_VERSION="1.0.0"
TRAEFIK_CHART_VERSION="10.20.1"
CERT_MANAGER_CHART_VERSION="1.7.2"

EPINIO_NAMESPACE="epinio"
TRAEFIK_NAMESPACE="traefik"
CERT_MANAGER_NAMESPACE="cert-manager"

get_values () {
  values=""
  if [ -z "$MP_KUBERNETES" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/epinio/values.yml"
  else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/epinio/values.yml"
  fi

  echo "$values"
}

update_repos () {
  helm repo add epinio https://epinio.github.io/helm-charts
  helm repo add jetstack https://charts.jetstack.io
  helm repo add traefik https://helm.traefik.io/traefik
  helm repo update > /dev/null
}

install_traefik () {
  helm upgrade traefik \
    traefik/traefik \
    --create-namespace \
    --install \
    --namespace "$TRAEFIK_NAMESPACE" \
    --version "$TRAEFIK_CHART_VERSION" \
    --set globalArguments='' \
    --set-string ports.web.redirectTo=websecure \
    --set-string ingressClass.enabled=true \
    --set-string ingressClass.isDefaultClass=true \
    --wait
}

install_cert_manager () {
  helm upgrade cert-manager \
    jetstack/cert-manager \
    --create-namespace \
    --install \
    --namespace "$CERT_MANAGER_NAMESPACE" \
    --version "$CERT_MANAGER_CHART_VERSION" \
    --set installCRDs=true \
    --set extraArgs[0]=--enable-certificate-owner-ref=true
}

install_epinio () {
  helm upgrade "$STACK" "$CHART" \
    --atomic \
    --create-namespace \
    --install \
    --namespace "$EPINIO_NAMESPACE" \
    --set global.domain="$2" \
    --values "$1" \
    --version "$CHART_VERSION"
}

wait_for_traefik_IP () {
  externalIP=""

  while [ -z "$externalIP" ]; do
    externalIP=$(kubectl get svc traefik -n "$TRAEFIK_NAMESPACE" --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
    [ -z "$externalIP" ] && sleep 5
  done

  echo "$externalIP"
}

# Script execution starts here

update_repos

EPINIO_VALUES=$(get_values)
export EPINIO_VALUES

echo "Installing traefik"
install_traefik

echo "Installing CertManager"
install_cert_manager

echo "Waiting for ingress controler IP address"
traefikIP=$(wait_for_traefik_IP)

echo "Installing $STACK"
install_epinio "$EPINIO_VALUES" "$traefikIP.omg.howdoi.website"
