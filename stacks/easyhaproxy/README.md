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

You can install the "Static Http Server"  and define the domain you want to validate as the example below:

```shell
helm repo add byjg https://opensource.byjg.com/helm
helm repo update
helm upgrade --install mysite byjg/static-httpserver \
    --namespace default \
    --set "ingress.hosts={www.example.org,example.org}" \
    --set parameters.title=Welcome
```


### EasyHAProxy Container not Starting

Due to limitations in the HAProxy community edition, EasyHAProxy functions solely as a standalone service, regardless of the number of nodes present.

If the node hosting EasyHAProxy experiences downtime, the service will remain unavailable until the node is operational again.

To restore connectivity, you have the option to deploy or upgrade the EasyHAProxy service.

