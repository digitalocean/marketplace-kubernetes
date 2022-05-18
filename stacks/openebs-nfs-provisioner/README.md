# Description

[OpenEBS Dynamic NFS PV provisioner](https://github.com/openebs/dynamic-nfs-provisioner) helps developers easily deploy Kubernetes Stateful Workloads that require fast and highly reliable [container attached storage](https://openebs.io/docs/concepts/cas). It can be used to dynamically provision NFS Volumes using different kinds of block storage available on the Kubernetes nodes. Using NFS Volumes, you can share Volume data across the pods running on different node machines. You can easily create NFS Volumes using OpenEBS Dynamic NFS Provisioner and use it anywhere.
[OpenEBS](https://openebs.io/docs) manages the storage available on each of the Kubernetes nodes and uses that storage to provide Local or Distributed(aka Replicated) Persistent Volumes to Stateful workloads.

**Note:** This stack requires a minimum configuration of 2 Nodes at the $10/month plan (2GB memory / 1 vCPU).

## OpenEBS Dynamic NFS Provisioner Overview Diagram

The following diagram shows how OpenEBS Dynamic NFS Provisioner works on a Kubernetes cluster in conjunction with a Wordpress deployment:

![OpenEBS Dynamic NFS Provisioner Overview](assets/images/arch_openebs.png)

## Software included

| Package               | Application Version   | Helm Chart Version |License                                                                                    |
| ---| ---- | ---- | ------------- |
| OpenEBS Dynamic NFS provisioner | 0.9.0 | [0.9.0](https://github.com/openebs/dynamic-nfs-provisioner) | [Apache 2.0](https://github.com/openebs/dynamic-nfs-provisioner/blob/develop/LICENSE) |

## Getting Started

### Connecting to Your Cluster

You can connect to your DigitalOcean Kubernetes cluster by following our [how-to guide](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/).

For additional instructions on configuring a [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/) cluster, see the following guides:

- [How to Set Up a DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks)
- [How to Set up DigitalOcean Container Registry](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/02-setup-DOCR#how-to-set-up-digitalocean-container-registry)

### Confirming that OpenEBS-nfs-provisioner is Running

First, verify that the Helm installation was successful by running following command:

```bash
helm ls -n openebs-nfs-provisioner
```

If the installation was successful, the `STATUS` column value in the output reads `deployed`:

```text
NAME                    NAMESPACE               REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
openebs-nfs-provisioner openebs-nfs-provisioner 1               2022-05-17 10:08:02.345252 +0300 EEST   deployed        nfs-provisioner-0.9.0   0.9.0 
```

Next, verify that the OpenEBS-nfs-provisioner pod is up and running with the following command:

```console
kubectl get pods --all-namespaces -l name=openebs-nfs-provisioner
```

If it's running, the pod listed in the output are in a `READY` state and the `STATUS` reads `Running`:

```text
NAMESPACE                 NAME                                       READY   STATUS    RESTARTS   AGE
openebs-nfs-provisioner   openebs-nfs-provisioner-5cfd76f4fc-5k7wf   1/1     Running   0          11m
```

### Tweaking Helm Values

The OpenEBS dynamic NFS provisioner stack provides some custom values to start with. Please have a look at the [values](./values.yml) file from the main GitHub repository.

You can always inspect all the available options, as well as the default values for the OpenEBS dynamic NFS provisioner Helm chart by running below command:

```console
helm show values helm show values openebs-nfs/nfs-provisioner --version 0.9.0 --version 0.9.0
```

After tweaking the Helm values file (`values.yml`) according to your needs, you can always apply the changes via `helm upgrade` command, as shown below:

```console
helm upgrade openebs-nfs-provisioner openebs-nfs/nfs-provisioner --version 0.9.0 \
  --namespace openebs-nfs-provisioner \
  --values values.yml
```

### Upgrading the OpenEBS Dynamic NFS Provisioner Chart

You can check what versions are available to upgrade by navigating to the [openebs/dynamic-nfs-provisioner](https://github.com/openebs/dynamic-nfs-provisioner) official releases page from GitHub.

To upgrade the stack to a newer version, run the following command, replacing the `< >` placeholders with their corresponding information:

```console
helm upgrade openebs-nfs-provisioner openebs-nfs/nfs-provisioner \
  --version <OPENEBS_DYNAMIC_NFS_PROVISIONER_STACK_NEW_VERSION> \
  --namespace openebs-nfs-provisioner \
  --values <YOUR_HELM_VALUES_FILE>
```

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

### Uninstalling

To uninstall openebs-nfs-provisioner, you need to have Helm 3 installed. Once installed, run the following `uninstall` command:

```bash
helm uninstall openebs-nfs-provisioner -n openebs-nfs-provisioner
```

And then the following `delete` commands:

```bash
kubectl delete ns openebs-nfs-provisioner
```

### Additional Resources

- [Documentation](https://openebs.io/docs)
- [OpenEBS Community Resources](https://openebs.io/community)
- [FAQ](https://openebs.io/faq)
