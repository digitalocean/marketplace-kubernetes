#!/bin/sh

set -e

kubectl delete -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gluu/yaml/gluu.yaml

