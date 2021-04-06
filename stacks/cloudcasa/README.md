# CloudCasa Kubernetes Agent

[CloudCasa](https://cloudcasa.io) - A Smart Home in the Cloud for Kubernetes Backups

## Introduction

CloudCasa is a SaaS solution that provides class-leading data protection services for Kubernetes and cloud native applications.
Configuration is quick and easy, and basic service is free.

This stack installs and configures the CloudCasa agent on a Kubernetes cluster.

## Prerequisites

1. Kubernetes 1.17+
2. Access to your cluster with kubectl

## Getting Started

After performing a 1-Click install of the CloudCasa agent, you will need to perform one more configuration step.
Log in to the CloudCasa portal at https://home.cloudcasa.io and obtain a cluster ID for this Kubernetes cluster.
To do that go to the "Protection" tab, fill in the required information, and click "Add New Cluster".
If the cluster has already been added, simply click on the cluster under the "Protection" tab and then click "Edit cluster".
Either way, you will be presented with the cluster ID.

Now use the following kubectl command to configure the agent, replacing `<cluster_id>` with the ID you obtained from the portal.

```
$ cat <<EOF | kubectl -n cloudcasa-io apply -f -
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: cloudcasa-config
    data:
      default: |
        cluster.id=<cluster_id>
EOF
```

That's it! You're done configuring the agent!
In the CloudCasa portal, you should soon see the cluster status change from "Pending" to "Active".
Then you can go ahead and configure your backups or perform restores.

### Getting Started with DigitalOcean Kubernetes

If you have problems connecting to your DigitalOcean Kuberenetes cluster using `kubectl` see:
https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/
 
Additional instructions are included in the DigitalOcean Kubernetes control panel:
https://cloud.digitalocean.com/kubernetes/clusters/ 
