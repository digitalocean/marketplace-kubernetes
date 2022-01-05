#!/bin/sh

set -e

if [ -z "${MP_KUBERNETES}" ]; then
  ROOT_DIR=$(git rev-parse --show-toplevel)

  # deploy local version of kapp-controller
  sh "$ROOT_DIR"/stacks/kapp-controller/deploy.sh

  # use local version of app.yml
  app="$ROOT_DIR/stacks/tekton-pipelines/app.yml"
else
  # deploy github hosted master version of kapp-controller
  sh -c "curl --location --silent --show-error https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kapp-controller/deploy.sh | sh"

  # use github hosted master version of app.yml
  app="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/tekton-pipelines/app.yml"
fi

kubectl apply -f $app
kubectl wait --for=condition=ReconcileSucceeded app/tekton -n kapp-tekton
