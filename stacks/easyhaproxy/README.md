# EasyHAProxy

[EasyHAProxy](https://easyhaproxy.com/) is an Ingress and Auto Discover service based on HAProxy.

HAProxy is an open-source, high-performance load balancer and reverse proxy designed for TCP and HTTP-based applications. Renowned for its stability, reliability, and performance, it is widely adopted in production environments.

EasyHAProxy combines HAProxy's robustness with seamless service discovery and exposure within Kubernetes clusters. It offers a straightforward method to configure Ingress rules for services using standard Kubernetes Ingress resources.

## Key Features

- Routes HTTP, HTTPS, and TCP traffic (e.g., MySQL server).
- Supports custom error messages.
- Integrates automatic SSL certificate issuance via Let's Encrypt (ACME).
- Supports custom SSL certificates.
- Automatically discovers services within the Kubernetes cluster.
- Facilitates the configuration of Ingress rules for services.
- Provides load balancing capabilities.
- Extends HAProxy with plugins (JWT validation, IP whitelisting, Cloudflare support, and more).

## How It Works

EasyHAProxy operates as a Kubernetes Ingress Controller. It queries all Ingress resources with `spec.ingressClassName: easyhaproxy` (or the deprecated annotation `kubernetes.io/ingress.class: easyhaproxy-ingress`). Upon finding a matching Ingress, EasyHAProxy automatically configures HAProxy and begins routing traffic.

## Install

1. Enable EasyHAProxy from the [DigitalOcean Marketplace](https://marketplace.digitalocean.com/apps/easyhaproxy-ingress-controller).
2. Create a DigitalOcean Load Balancer pointing to your Kubernetes cluster.

## Deployment Configuration

EasyHAProxy can be deployed in two ways:

1. **Deployment with Service (default in DO Marketplace)**: EasyHAProxy runs as a standard Deployment with a ClusterIP Service, allowing Kubernetes to schedule it on any available node. This is the recommended approach for DigitalOcean and is configured with `service.create: true`.

2. **DaemonSet with node affinity**: For advanced configurations, EasyHAProxy can run as a DaemonSet restricted to a specific node (labeled `easyhaproxy/node=master`). Set `service.create: false` to use this mode.

> **Note:** EasyHAProxy is designed for single replica deployment. Running multiple replicas can cause ACME certificate issuance failures and temporary service discovery inconsistencies. See [Limitations](https://easyhaproxy.com/docs/limitations) for details.

## How to Set Up Your Application for EasyHAProxy

Add the `spec.ingressClassName: easyhaproxy` field to your application's Ingress resource:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: example
spec:
  ingressClassName: easyhaproxy
  rules:
  - host: example.org
    http:
      paths:
      - backend:
          service:
            name: example-service
            port:
              number: 8080
        pathType: ImplementationSpecific
```

EasyHAProxy will automatically detect the Ingress and start routing traffic from `example.org:80` to your service. You do not need to expose ports 80 or 443 directly on your backend containers — HAProxy handles all incoming traffic.

> **Backward compatibility:** The annotation `kubernetes.io/ingress.class: easyhaproxy-ingress` is still supported but deprecated. Use `spec.ingressClassName` for new deployments.

## SSL / HTTPS

### Automatic Certificates (Let's Encrypt / ACME)

Enable automatic SSL certificates for a domain by adding the `easyhaproxy.certbot` annotation:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: example
  annotations:
    easyhaproxy.certbot: "true"
spec:
  ingressClassName: easyhaproxy
  rules:
  - host: example.org
    http:
      paths:
      - backend:
          service:
            name: example-service
            port:
              number: 8080
        pathType: ImplementationSpecific
```

Requirements for ACME to work:
- Ports 80 and 443 must be publicly accessible.
- DNS must point to your cluster's Load Balancer.
- Set `EASYHAPROXY_CERTBOT_EMAIL` in the EasyHAProxy configuration.

### Custom SSL Certificates

You can bring your own certificates using a Kubernetes TLS Secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-tls-secret
  namespace: default
data:
  tls.crt: <base64-encoded-certificate>
  tls.key: <base64-encoded-private-key>
type: kubernetes.io/tls

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-example
  namespace: default
spec:
  ingressClassName: easyhaproxy
  tls:
  - hosts:
    - example.org
    secretName: my-tls-secret
  rules:
  - host: example.org
    http:
      paths:
      - backend:
          service:
            name: example-service
            port:
              number: 8080
        pathType: ImplementationSpecific
```

## Kubernetes Annotations Reference

| Annotation                          | Description                                                          | Default    | Example                  |
|-------------------------------------|----------------------------------------------------------------------|------------|--------------------------|
| easyhaproxy.redirect_ssl            | Force redirect all endpoints to HTTPS.                               | false      | true or false            |
| easyhaproxy.certbot                 | Request automatic SSL certificate via ACME/Let's Encrypt.            | false      | true or false            |
| easyhaproxy.redirect                | JSON key-value pairs mapping domains to redirect destinations.        | *empty*    | `{"domain":"target_url"}`|
| easyhaproxy.mode                    | Set connection mode.                                                 | http       | http or tcp              |
| easyhaproxy.listen_port             | Override the HTTP listen port for this Ingress.                      | 80         | 8081                     |
| easyhaproxy.plugins                 | Comma-separated list of plugins to enable.                           | *empty*    | cloudflare,deny_pages    |

## Additional Resources

- [EasyHAProxy Documentation](https://easyhaproxy.com/)
- [EasyHAProxy on DigitalOcean Marketplace](https://marketplace.digitalocean.com/apps/easyhaproxy-ingress-controller)
- [GitHub Repository](https://github.com/byjg/docker-easy-haproxy)

## Troubleshooting

### Verify EasyHAProxy is Running

Check that the EasyHAProxy pod is running:

```shell
kubectl get pods -n easyhaproxy
```

Check logs for errors:

```shell
kubectl logs -n easyhaproxy -l app=easyhaproxy --tail=100
```

### Test with a Simple HTTP Server

Install the Static HTTP Server to verify EasyHAProxy is routing traffic correctly:

```shell
helm repo add byjg https://opensource.byjg.com/helm
helm repo update
helm upgrade --install mysite byjg/static-httpserver \
    --namespace default \
    --set "ingress.hosts={www.example.org,example.org}" \
    --set parameters.title=Welcome
```

### Modify EasyHAProxy Configuration

To update the EasyHAProxy configuration (e.g., log levels or resource requests), use Helm:

```bash
helm upgrade --install easyhaproxy byjg/easyhaproxy \
  --namespace easyhaproxy \
  --set easyhaproxy.logLevel.certbot=INFO \
  --set easyhaproxy.logLevel.easyhaproxy=INFO \
  --set easyhaproxy.logLevel.haproxy=INFO \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=128Mi \
  --set service.create=true
```

### EasyHAProxy Container Not Starting

When using the default DigitalOcean Marketplace configuration (`service.create: true`), EasyHAProxy runs as a Deployment and can be scheduled on any node. If the pod is not starting:

1. Check pod events: `kubectl describe pod -n easyhaproxy -l app=easyhaproxy`
2. Verify the Load Balancer is properly configured.
3. Reinstall using the Helm upgrade command above.

If using DaemonSet mode (`service.create: false`), ensure a node is labeled:

```bash
kubectl label nodes <node-name> "easyhaproxy/node=master"
```
