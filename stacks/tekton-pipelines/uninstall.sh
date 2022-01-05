#!/bin/sh

set -e

kubectl delete -n kapp-tekton app tekton
kubectl delete clusterrolebinding kapp-tekton-deployer-admin
kubectl delete namespace kapp-tekton
