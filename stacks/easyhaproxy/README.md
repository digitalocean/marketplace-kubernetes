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

Enable EasyHAProxy from the [DigitalOcean Marketplace](https://marketplace.digitalocean.com/apps/easyhaproxy-ingress-controller).

The stack creates a DigitalOcean Load Balancer for you. Point your domains to its address:

```shell
kubectl get svc -n easyhaproxy easyhaproxy
```

The address is in the `EXTERNAL-IP` column; it can take a minute or two to appear. EasyHAProxy also writes it to the status of every Ingress it serves (`kubectl get ingress -A`).

## What Gets Deployed

| Resource | Details |
|---|---|
| Deployment `easyhaproxy` | One replica; Kubernetes can schedule it on any node. |
| Service `easyhaproxy` (type `LoadBalancer`) | DigitalOcean creates a Load Balancer for it, forwarding ports 80 and 443 (stats ports only if you enable them). |
| PersistentVolumeClaim `easyhaproxy-certbot` (1 Gi) | Keeps the Let's Encrypt certificates across restarts. |
| IngressClass `easyhaproxy` | Select EasyHAProxy with `spec.ingressClassName: easyhaproxy`. |

> **Cost:** the DigitalOcean Load Balancer and the 1 Gi block storage volume are billed to your account. See [DigitalOcean pricing](https://www.digitalocean.com/pricing).

> **Run a single replica.** Do not scale the `easyhaproxy` Deployment. Each replica runs its own Let's Encrypt (ACME) client: the Load Balancer can send a challenge to a replica that did not request it, so certificates fail, and the replicas together can hit the Let's Encrypt rate limits. The stack sets `replicaCount: 1`, and upgrades use the `Recreate` strategy, so two copies never run side by side. If you need several replicas for high availability, do not use ACME; provide certificates as TLS secrets (see [Custom SSL Certificates](#custom-ssl-certificates)). See [Limitations](https://opensource.byjg.com/docs/devops/docker-easy-haproxy/concepts/limitations/) for details.

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
- DNS for the domain must point to the Load Balancer address (see [Install](#install)).
- Set the e-mail used to register with Let's Encrypt. It is not set by default:

```shell
helm upgrade easyhaproxy byjg/easyhaproxy \
  --namespace easyhaproxy \
  --reset-then-reuse-values \
  --set easyhaproxy.certbot.email=you@example.com
```

Issued certificates are stored on the `easyhaproxy-certbot` volume, so they survive restarts and upgrades.

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
kubectl logs -n easyhaproxy -l app.kubernetes.io/name=easyhaproxy --tail=100
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

To change the configuration (e.g., log levels), use Helm. `--reset-then-reuse-values` (Helm 3.14 or later) keeps the values you set before:

```bash
helm upgrade easyhaproxy byjg/easyhaproxy \
  --namespace easyhaproxy \
  --reset-then-reuse-values \
  --set easyhaproxy.logLevel.certbot=INFO \
  --set easyhaproxy.logLevel.easyhaproxy=INFO \
  --set easyhaproxy.logLevel.haproxy=INFO
```

### Stats Page and Dashboard

They are disabled by default, because the Load Balancer would expose them to the internet. To enable them, always with a password (without one they are served without a login):

```bash
helm upgrade easyhaproxy byjg/easyhaproxy \
  --namespace easyhaproxy \
  --reset-then-reuse-values \
  --set easyhaproxy.stats.enabled=true \
  --set easyhaproxy.stats.password='<a strong password>'
```

The Load Balancer then serves the stats page on port 1936 (user `admin`) and the dashboard on port 11936.

### EasyHAProxy Container Not Starting

1. Check pod events: `kubectl describe pod -n easyhaproxy -l app.kubernetes.io/name=easyhaproxy`
2. Check the Load Balancer was created: `kubectl get svc -n easyhaproxy easyhaproxy` and the events from `kubectl describe svc -n easyhaproxy easyhaproxy`.
3. Check the certificate volume is bound: `kubectl get pvc -n easyhaproxy`.

## Upgrading from an Earlier Version of This Stack

Earlier versions of this stack ran EasyHAProxy as a DaemonSet bound to ports 80/443 of the node labeled `easyhaproxy/node=master`, with your DNS pointing to that node. Upgrading replaces it with the Deployment and a new DigitalOcean Load Balancer, **with a new IP address**:

1. Run the upgrade (`upgrade.sh`, or the Helm command above).
2. Get the Load Balancer address: `kubectl get svc -n easyhaproxy easyhaproxy`.
3. Point your DNS records to that address. Until then your sites are not reachable.
4. Remove the node label, which is no longer used: `kubectl label nodes --all easyhaproxy/node-`.
