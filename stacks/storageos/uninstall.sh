#!/bin/sh

set -e

kubectl delete -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/storageos/yaml/storageos-operator.yaml
kubectl delete -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/storageos/yaml/storageos-cluster.yaml
