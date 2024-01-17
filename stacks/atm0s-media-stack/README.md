# Atm0s Media Server Stack

## Prerequisites

1. Kubernetes >= 1.23+
2. Access to your cluster with kubectl and helm

## Getting Started

Everything should be setup properly after installing.

## Firewalls
For the stack's node to communicate with each others, the pods will be using `hostNetwork`, so you will need to set some Inbound TCP and UDP Rules for each of the service's ports you've enabled.

## Getting Started with DigitalOcean Kubernetes

If you have problems connecting to your DigitalOcean Kuberenetes cluster using `kubectl` see:
https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/
 
Additional instructions are included in the DigitalOcean Kubernetes control panel:
https://cloud.digitalocean.com/kubernetes/clusters/ 

For testing, you can follow to: https://<YOUR HOST>/samples

For further supports, you can join our Discord Channel: https://discord.gg/9CrAZUrHse