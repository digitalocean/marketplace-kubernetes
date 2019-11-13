#!/bin/sh

set -e

# deploy nginx ingress
sh -c "curl --location --silent --show-error https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/nginx-ingress/deploy.sh | sh"

# create mysql-operator namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: mysql-operator
EOF

# deploy mysql-operator
kubectl apply -n mysql-operator -f https://raw.githubusercontent.com/mattermost/mattermost-operator/v0.8.0/docs/mysql-operator/mysql-operator.yaml

# create minio-operator namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: minio-operator
EOF

# deploy minio-operator
kubectl apply -n minio-operator -f https://raw.githubusercontent.com/mattermost/mattermost-operator/v0.8.0/docs/minio-operator/minio-operator.yaml

# create mattermost-operator namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: mattermost-operator
EOF

# deploy mattermost-operator
kubectl apply -n mattermost-operator -f https://raw.githubusercontent.com/mattermost/mattermost-operator/v0.8.0/docs/mattermost-operator/mattermost-operator.yaml

# ensure services are running
kubectl rollout status -w deployment/mattermost-operator -n mattermost-operator
kubectl rollout status -w deployment/minio-operator -n minio-operator
kubectl rollout status -w statefulset/mysql-operator -n mysql-operator
