<h1 align="center">
  <img src="https://otomi.io/img/otomi-logo.svg" width="224px"/><br/>
  Self-hosted PaaS for Kubernetes
</h1>
<p align="center"><b>Deploy your apps fast and safe on any Kubernetes cluster in any cloud</b></p>

## Description

[Otomi](https://github.com/redkubes/otomi-core) adds developer- and operations-centric tools, automation, and self-service on top of Kubernetes in any infrastructure or cloud, to code, build, and run containerized applications 


**Notes:**

- This stack requires a minimum configuration of 4 nodes at the $0.13/hour plan (2.5GB memory/2 vCPUs)
- If you have access to `professional plans`, then we recommend using a configuration of 3 nodes at the $0.19/hour plan (6 GB/ 4vCPUs)
- Otomi is installed with an auto-generated CA and uses the public IP of the load balancer with nip.io for all hostnames. See the Otomi [documentation](https://otomi.io/docs/installation/optional) for advanced configurations using DNS, value encryption, Let's Encrypt and Azure Active Directory as IdP.

## Software included

| Package               | Application Version   |License                                                                                    |
| ---| ---- | ------------- |
| otomi | [v1.x.x](https://github.com/redkubes/otomi-core/releases/) | [Apache 2.0](https://github.com/redkubes/otomi-core/blob/main/LICENSE) |

## Getting Started

### Prerequisites
Get familiar with supported kubernetes versions at https://otomi.io/product/roadmap

### How to Connect to Your Cluster

Follow these [instructions](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/) to connect to your cluster with `kubectl` and `doctl`.

### Confirming that Otomi is Running

First, check if the Otomi installation was successful by running the command below:

```bash
kubectl get job otomi -w
```

The output looks similar to the following:

```text
NAME    COMPLETIONS   DURATION   AGE
otomi   1/1           14m        14m
```
  
Next, check the installer job logs to get the otomi console `url` and `credentials` by running the following command:

```bash
kubectl logs jobs/otomi -n default --tail=7
```
### Accessing Otomi console

For activation steps follow: https://otomi.io/docs/get-started/activation

For performing hands-on labs look into: https://otomi.io/docs/for-devs/get-started/overview

## Upgrade Instructions

Upgrading to a new version of Otomi can be easily done via the `otomi-console`. 
From the left menu bar follow: `Settings` then in rhe main screen click `Otomi` and find `Version` input form. Fill a new version


```bash
NOTE:
# The major and minor upgrades must be incremental, e.g.: 1.16.4 -> 1.17.0
```

### Additional Resources

- [Otomi Documentation](https://otomi.io/docs/get-started/installation)
- [Otomi Slack](https://otomi.slack.com/ssb/redirect#/shared-invite/email)

