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
