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

For additional instructions on configuring a [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/) cluster, see the following [guide](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks).

### Confirming that OpenEBS NFS Provisioner is Running

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

### Integrating OpenEBS Dynamic NFS Provisioner with Wordpress

DigitalOcean Block Storage Volumes are mounted as read-write by a single node (RWO). Additional nodes cannot mount the same volume. The data content of a PersistentVolume can not be accessed by multiple Pods simultaneously.

Horizontal pod autoscaling (HPA) is used to scale the WordPress Pods in a dynamically StatefulSet, hence WordPress requires a [volume](https://kubernetes.io/docs/concepts/storage/volumes/) mounted as read-write by many nodes (RWX).

This installation also creates a `storage class` called `rwx-storage` to diynamically provision shared volumes on top of the default Kubernetes Storage Class (do-block-storage) provided by DigitalOcean as the backend storage for the NFS provisioner. In that case, whichever application uses the newly created Storage Class, can consume shared storage (NFS) on a DigitalOcean volume using OpenEBS NFS provisioner.

**Note:**
For more information about the `storage class` created please see its [manifest](./assets/manifests/sc-rwx.yaml) file from the main GitHub repository.

You would integrate this in a typical Wordpress manifest by adding the `storageClassName` in the `persistence` block:

```yaml
...
# Enable persistence using Persistent Volume Claims
persistence:
  enabled: true
  storageClassName: rwx-storage
  accessModes: ["ReadWriteMany"]
  size: 5Gi
...
```

**Note:**
For more information on this setup please visit the [DOKS-Wordpress](https://github.com/digitalocean/container-blueprints/tree/main/DOKS-wordpress) blueprint.

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

## Uninstalling OpenEBS NFS Provisioner Stack

To delete your installation of `openebs-nfs-provisioner,`, run the following command:

```console
helm uninstall openebs-nfs-provisioner -n openebs-nfs-provisioner
```

**Note:**

The command will delete all the associated Kubernetes resources installed by the `openebs-nfs-provisioner` Helm chart, except the namespace itself. To delete the `openebs-nfs-provisioner namespace` as well, run the following command:

```console
kubectl delete ns openebs-nfs-provisioner
```

### Additional Resources

- [OpenEBS NFS provisioner GitHub page](https://github.com/openebs/dynamic-nfs-provisioner)
