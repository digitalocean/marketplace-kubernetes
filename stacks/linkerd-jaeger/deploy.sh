#!/bin/sh

set -e


# # Install the CLI
curl -sL https://run.linkerd.io/install | sh

export PATH=$PATH:$HOME/.linkerd2/bin

# # verify the CLI
# # linkerd version

# # Validate your Kubernetes cluster
# # linkerd check --pre

# # Install Linkerd onto the cluster
linkerd install | kubectl apply -f -


# #add distributed tracing with linkerd

cat >> config.yaml << EOF
tracing:
  enabled: true
  collector:
    resources:
      cpu:
        limit: 100m
        request: 1m
      memory:
        limit: 100Mi
        request: 1Mi
EOF

linkerd upgrade --addon-config config.yaml | kubectl apply -f -

rm -rf config.yaml
# ---------


# # check linkerd pod running
# kubectl get pod -n linkerd

# # expose UI
# kubectl -n linkerd port-forward linkerd-web-pod-name 8084:8084

# # inject linkerd to deployment in loki namsespace and analyze in browser localhost:8084
# kubectl -n loki get deploy -o yaml | linkerd inject - | kubectl apply -f -

# # uninject linkerd 
# kubectl -n loki get deploy -o yaml | linkerd uninject - | kubectl apply -f -

# #uninstall linderd    
# linkerd install --ignore-cluster | kubectl delete -f -

