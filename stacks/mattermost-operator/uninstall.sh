#!/bin/sh

set -e

kubectl delete --ignore-not-found=true namespace mysql-operator
kubectl delete --ignore-not-found=true namespace minio-operator
kubectl delete --ignore-not-found=true namespace mattermost-operator