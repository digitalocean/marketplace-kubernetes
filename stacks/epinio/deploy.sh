#!/bin/sh

set -e

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
. "$SCRIPT_DIR/common.sh"

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
