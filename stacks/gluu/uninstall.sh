#!/bin/sh

set -e

kubectl delete --ignore-not-found=true -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gluu/yaml/gluu.yaml

