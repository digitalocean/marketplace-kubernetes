# Getting started

The minimum cluster size is 2 nodes (2 cpu 2Gi each).

### Deploying and accessing PostHog 

1. Your application will be hosted at an ingress IP because hostname was not supplied. Run these commands to get your installation location:
```bash
export INGRESS_IP=$(kubectl get --namespace posthog ingress posthog -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo "Visit http://$INGRESS_IP to use PostHog\!"
```

You should now be able to navigate to PostHog at the location printed out to your terminal!

You are now all set up to start trying PostHog!

But there's one more important step before using PostHog in production: securing your instance. See [our DigitalOcean deployment docs](<https://posthog.com/docs/self-host/deploy/digital-ocean#securing-your-1-click-install>).
