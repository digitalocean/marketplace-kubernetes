#!/bin/sh

set -e

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: storageos
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=storageos

# deploy storageos operator
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/storageos/yaml/storageos-operator.yaml

# ensure operator is running
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  kubectl rollout status -w deployment/"$line"
done

# create admin credentials.  Auto-generate the admin password if we can.
username="admin"
password="storageos"
if [ -x /usr/bin/pwgen ]; then
  password=`/usr/bin/pwgen 12 1`
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: storageos-api
  namespace: storageos
  labels:
    app: storageos-operator
    chart: storageos-operator-0.2.16
    heritage: Tiller
    release: storageos
type: "kubernetes.io/storageos"
data:
  apiUsername: "`echo -n "$username" | base64`"
  apiPassword: "`echo -n "$password" | base64`"
EOF

echo "Created administrator credentials, username: $username, password: $password"

# deploy storageos cluster
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/storageos/yaml/storageos-cluster.yaml

# ensure cluster is running
until kubectl -n storageos get storageoscluster storageos --no-headers -o go-template='{{.status.phase}}' | grep -q "Running"; do sleep 5; done
