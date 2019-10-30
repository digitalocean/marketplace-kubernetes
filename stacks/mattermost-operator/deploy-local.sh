#!/bin/sh

set -e

# create mysql-operator namespace
kubectl create ns mysql-operator
# deploy mysql-operator
kubectl apply -n mysql-operator -f https://raw.githubusercontent.com/mattermost/mattermost-operator/v0.7.0/docs/mysql-operator/mysql-operator.yaml

# create minio-operator namespace
kubectl create ns minio-operator
# deploy minio-operator
kubectl apply -n minio-operator -f https://raw.githubusercontent.com/mattermost/mattermost-operator/v0.7.0/docs/minio-operator/minio-operator.yaml

# create mattermost-operator namespace
kubectl create ns mattermost-operator
# deploy mattermost-operator
$ kubectl apply -n mattermost-operator -f https://raw.githubusercontent.com/mattermost/mattermost-operator/v0.7.0/docs/mattermost-operator/mattermost-operator.yaml


# ensure services are running
kubectl rollout status deployment/mattermost-operator -n mattermost-operator
kubectl rollout status deployment/minio-operator -n minio-operator
kubectl rollout status statefulset/mysql-operator -n mysql-operator