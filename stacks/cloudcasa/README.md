# CloudCasa Kubernetes Agent

[CloudCasa](https://cloudcasa.io) - *Leader in Kubernetes Data Protection and Application Resiliency*

## Introduction

CloudCasa is a data protection, disaster recovery, replication, and migration service for Kubernetes and cloud-native applications.
It is fully compatible with DigitalOcean Kubernetes and with Spaces object storage.
Configuration is quick and easy, and basic service is free.

This stack installs and configures the CloudCasa agent on a Kubernetes cluster.

## Prerequisites

1. Kubernetes 1.20+
2. Access to your cluster with kubectl

## Getting Started

After performing a 1-Click install of the CloudCasa agent, you will need to perform one more configuration step.
Log in to the CloudCasa portal at https://home.cloudcasa.io to register your cluster and obtain a cluster ID.
To do that, go to the **Clusters/Overview** page, click "Add Cluster", and fill in the required information.
The Cluster ID will be displayed at the top of the page.
If the cluster has previously been added, you can retrieve the cluster ID by simply clicking on the cluster on the **Clusters/Overview** page.
The cluster ID will be displayed after the name on the cluster dashboard page.

Now use the following kubectl command to configure the agent, replacing `<cluster_id>` with the ID you obtained from CloudCasa.

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
In the CloudCasa portal, you should soon see the cluster state change from "Registered" to "Active".
Then you can go ahead and configure your backups or perform restores.

See the [CloudCasa documentation](https://docs.cloudcasa.io/help/) for more details.

### Getting Started with DigitalOcean Kubernetes

If you have problems connecting to your DigitalOcean Kuberenetes cluster using `kubectl` see:
https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/
 
Additional instructions are included in the DigitalOcean Kubernetes control panel:
https://cloud.digitalocean.com/kubernetes/clusters/ 
