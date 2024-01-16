# Atm0s Media Server Stack

## Prerequisites

1. Kubernetes 1.17+
2. Access to your cluster with kubectl and helm

### Firewalls
For the stack's node to communicate with each others, the pods will be using `hostNetwork`, so you will need to set some Inbound TCP and UDP Rules for each of the service's ports you've enabled.


## Getting Started

After performing a 1-Click install of the Atm0s Media Server stack, you will need to perform some configuration steps.
The stack will initialize with only a Gateway node. This will act as a seed for other nodes to join the network.
For that, we will need the multi-address of the gateway node.
Using kubectl, logs the Gateway node using: 
Get the pods in atm0s-media namespace to retrieve gateway pod name:

```
kubectl get pod -n atm0s-media
```

The pod name will be something like: atm0s-media-gateway-xxxx-xxx
Now you can get the gateway pod logs to acquire the seed address:

```
> kubectl logs atm0s-media-gateway-xxxx-xxx

outputs...
[ServerAtm0s] node addr: 0@/ip4/192.168.65.3/udp/3001/ip4/192.168.65.3/tcp/3001  
...  
```

Next, get the default `values.yaml`: https://github.com/8xFF/helm/blob/main/charts/atm0s-media/values.yaml
Then modify the `seedAddr` and enable your favorite services to get up and running.

### Getting Started with DigitalOcean Kubernetes

If you have problems connecting to your DigitalOcean Kuberenetes cluster using `kubectl` see:
https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/
 
Additional instructions are included in the DigitalOcean Kubernetes control panel:
https://cloud.digitalocean.com/kubernetes/clusters/ 
