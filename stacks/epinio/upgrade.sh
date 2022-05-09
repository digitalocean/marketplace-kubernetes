#!/bin/sh

set -e

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
. "$SCRIPT_DIR/common.sh"

update_repos

EPINIO_VALUES=$(get_values)
export EPINIO_VALUES

echo "Upgrading traefik"
install_traefik

echo "Upgrading CertManager"
install_cert_manager

echo "Upgrading $STACK"
upgrade_epinio "$EPINIO_VALUES"
