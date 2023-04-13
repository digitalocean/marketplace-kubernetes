#!/bin/sh

# SPDX-FileCopyrightText: © 2019–2022 DigitalOcean
# SPDX-License-Identifier: Apache-2.0

set -e

################################################################################
# chart
################################################################################
STACK="pachyderm"
NAMESPACE="pachyderm"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

kubectl delete pvc -n "$NAMESPACE" -l suite=pachyderm -l release=pachyderm
