# EasyHAProxy

[EasyHAProxy](https://easyhaproxy.com/) is an Ingress and Auto Discover service based on HAProxy.

HAProxy is an open-source, high-performance load balancer and reverse proxy designed for TCP and HTTP-based applications. Renowned for its stability, reliability, and performance, it is widely adopted in production environments.

EasyHAProxy combines HAProxy's robustness with seamless service discovery and exposure within Kubernetes clusters. It offers a straightforward method to configure Ingress rules for services.

Key Features

- Handles and routes HTTP, HTTPS, and TCP traffic (e.g., MySQL server).
- Supports custom error messages.
- Integrates Let's Encrypt SSL certificate functionality.
- Automatically discovers services within the Kubernetes cluster.
- Facilitates the configuration of Ingress rules for services.
- Provides load balancing capabilities.

## Install

- Enable the EasyHAProxy in the Digital Ocean marketplace
- Create a Digital Ocean Load Balance pointing to your Kubernetes Cluster. 

## Deployment Configuration

EasyHAProxy can be deployed in two ways:

1. **Deployment with Service (default in DO Marketplace)**: EasyHAProxy is deployed as a Deployment with a Service (ClusterIP), allowing it to run on any available node in the cluster. This is configured with `service.create: true`.

2. **DaemonSet with node affinity**: For advanced configurations, you can deploy EasyHAProxy as a DaemonSet with node affinity by setting `service.create: false`. In this mode, EasyHAProxy will only run on nodes with the specified label.

## How to set up your application for EasyHAProxy

You need to add to your application ingress annotations to expose your service to the internet.

```yaml
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: easyhaproxy-ingress
  .
  .
  .
```

## Additional Resources

For further details about EasyHAProxy, please refer to the [documentation](https://easyhaproxy.com/).

## Troubleshooting

### Check if the EasyHAProxy is running properly

You can install the "Static Http Server" and define the domain you want to validate as the example below:

```shell
helm repo add byjg https://opensource.byjg.com/helm
helm repo update
helm upgrade --install mysite byjg/static-httpserver \
    --namespace default \
    --set "ingress.hosts={www.example.org,example.org}" \
    --set parameters.title=Welcome
```

### EasyHAProxy Configuration

If you need to modify the EasyHAProxy configuration (such as changing log levels or resource requests), you can use the following command:

If you want to use the default values:

```bash
helm upgrade --install easyhaproxy byjg/easyhaproxy
```

or if you want to change the default values and replacing by a new ones:

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

### EasyHAProxy Container not Starting

When using the DaemonSet deployment mode (`service.create: false`), EasyHAProxy will only run on nodes with the specified label due to HAProxy community edition limitations. 

If you're using the default Digital Ocean Marketplace configuration (`service.create: true`), EasyHAProxy will run as a regular Deployment with a Service, which provides better resilience as it can be scheduled on any available node in the cluster.

If you experience issues, you can restore connectivity by redeploying or upgrading the EasyHAProxy service using the Helm upgrade command shown above. 