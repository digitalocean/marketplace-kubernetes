# Getting started

### Minimum requirements

Please make sure that each node in the Kubernetes node pool has the following specifications - 

```
8 GB RAM, 4 vCPUs
```

Please use a minimum of 2 nodes in the deployment.

### Deploying and accessing PostHog 

1. Your application will be hosted at an ingress IP because hostname was not supplied. Run these commands to get your installation location:
```bash
export INGRESS_IP=$(kubectl get --namespace posthog ingress posthog -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo "Visit http://$INGRESS_IP to use PostHog\!"
```

You should now be able to navigate to PostHog at the location printed out to your terminal!

You are now all set up to start trying PostHog!

#### Securing your 1-click install

Sadly it's not possible to provide parameters to DigitalOcean yet, so we need post-install steps to enable TLS.

1. Create a DNS record from your desired hostname to the external IP (`kubectl get --namespace posthog ingress posthog -o jsonpath="{.status.loadBalancer.ingress[0].ip}"`).
2. Create `values.yaml`
```yaml
cloud: "do"
ingress:
  hostname: <your-hostname>
  nginx:
    enabled: true
certManager:
  enabled: true
```
3. Run the upgrade (note that if you used the UI for install, you'll need to follow the getting started guide to setup kubeconfig, if you skipped it earlier use the "Remind me how to do this" link on the Kubernetes cluster tab)

```console
helm repo add posthog https://posthog.github.io/charts-clickhouse/
helm repo update
helm upgrade -f values.yaml --timeout 20m --namespace posthog posthog posthog/posthog
```
