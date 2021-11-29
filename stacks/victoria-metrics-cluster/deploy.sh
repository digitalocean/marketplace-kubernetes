#!/bin/sh

set -e


# Add VictoriaMetrics Helm repository

helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update > /dev/null

# Install the VM Operator from the Helm chart
helm install vmoperator vm/victoria-metrics-operator

# Install VictoriaMetrics Cluster with CRDs
cat << EOF | kubectl apply -f -
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMCluster
metadata:
  name: vmcluster
spec:
  # Add fields here
  retentionPeriod: "12"
  vmstorage:
    replicaCount: 2
  vmselect:
    replicaCount: 2
  vminsert:
    replicaCount: 2
EOF

# Install VMAgent. Get more information on https://docs.victoriametrics.com/vmagent.html
cat <<EOF | kubectl apply -f -
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAgent
metadata:
  name: vmagent
spec:
  serviceScrapeNamespaceSelector: {}
  podScrapeNamespaceSelector: {}
  podScrapeSelector: {}
  serviceScrapeSelector: {}
  nodeScrapeSelector: {}
  nodeScrapeNamespaceSelector: {}
  staticScrapeSelector: {}
  staticScrapeNamespaceSelector: {}
  replicaCount: 1
  remoteWrite:
    - url: "http://vminsert-vmcluster-persistent.default.svc.cluster.local:8480/insert/0/prometheus/api/v1/write"
EOF
