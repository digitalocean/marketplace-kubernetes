#!/bin/sh

# SPDX-FileCopyrightText: © 2019–2022 DigitalOcean
# SPDX-FileCopyrightText: © 2022 Pachyderm, Inc. <info@pachyderm.com>
# SPDX-License-Identifier: Apache-2.0

set -e

################################################################################
# repo
################################################################################
helm repo add pachyderm https://helm.pachyderm.com
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="pachyderm"
CHART="pachyderm/pachyderm"
NAMESPACE="pachyderm"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/pachyderm/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/pachyderm/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
     --namespace "$NAMESPACE" \
     --values "$values" \
     --set-string pachd.clusterDeploymentID=$(kubectl get secret -n "$NAMESPACE" pachyderm-deployment-id-secret -o yaml | grep CLUSTER_DEPLOYMENT_ID | awk '{print $2}' | base64 -d)
