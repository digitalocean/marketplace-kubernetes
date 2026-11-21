# Description

[Denpex GPU & NCCL Watcher](https://denpex.com) (`denpex-gpu-watcher`) monitors every GPU node in your DigitalOcean Kubernetes (DOKS) cluster for NVIDIA Xid hardware errors, uncorrectable ECC faults, CUDA out-of-memory crashes, and NCCL timeouts, running deterministic diagnosis directly on the node.

By default, nothing leaves your cluster unless you configure an optional Denpex API key.

# Getting Started

After installing the 1-Click App, confirm the watcher DaemonSet pods are scheduled on your GPU nodes:

```bash
kubectl get pods -n denpex-gpu-watcher -o wide
```

View real-time node diagnostics from a watcher pod:

```bash
kubectl logs -n denpex-gpu-watcher -l app.kubernetes.io/name=denpex-gpu-watcher --tail=100
```

## Optional: Enable Cloud Deep Diagnosis & Alerts

To connect your cluster to the Denpex Dashboard, Slack alerts, and all 14 GPU fleet diagnostic tools:

1. Start a free 30-day Team trial (work email, no credit card) at [denpex.com/pricing](https://denpex.com/pricing?utm_source=digitalocean_marketplace).
2. Create a Kubernetes Secret with your API key and point `denpex.existingSecret` to it:

```bash
kubectl -n denpex-gpu-watcher create secret generic denpex-api-key \
  --from-literal=DENPEX_API_KEY="YOUR_DENPEX_API_KEY"

helm upgrade denpex-gpu-watcher denpex/denpex-gpu-watcher \
  --namespace denpex-gpu-watcher \
  --set denpex.existingSecret=denpex-api-key
```

## Documentation & Support

- Docs & Integrations: https://denpex.com/docs/integrations
- Helm Chart Source: https://github.com/Denpex/helm-charts
- Support: support@denpex.com
