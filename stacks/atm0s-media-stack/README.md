# Atm0s Media Server Stack

## Prerequisites

1. Kubernetes >= 1.23+
2. Access to your cluster with kubectl and helm

## Getting Started

### Setup you host
By default the cluster will be receiving request from your Ingress Controller IP. To setup your host:
- You need to have `kubectl` and `helm` setup.
- Get the default `values.yaml` here: https://github.com/8xFF/helm/blob/main/charts/atm0s-media/values.yaml
- Update the `gateway.host` property with your hostname.
- Run `helm upgrade -f <path/to/values.yaml> atm0s-media-stack 8xff/atm0s-media-stack -n atm0s-media`

### Usage
Due to URL Rewrite, the every request to gateway or authentication will need to be prefixed with `/gateway` and `/auth` respectively.
For more detail: https://github.com/8xFF/atm0s-media-server

## Firewalls
For the stack's node to communicate with each others, the pods will be using `hostNetwork`, so you will need to set some Inbound TCP and UDP Rules for each of the service's ports you've enabled.

## Getting Started with DigitalOcean Kubernetes

If you have problems connecting to your DigitalOcean Kuberenetes cluster using `kubectl` see:
https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/
 
Additional instructions are included in the DigitalOcean Kubernetes control panel:
https://cloud.digitalocean.com/kubernetes/clusters/ 

For further supports, you can join our Discord Channel: https://discord.gg/9CrAZUrHse