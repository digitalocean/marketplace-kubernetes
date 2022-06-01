# Description

The [OpenEBS Dynamic NFS Provisioner](https://github.com/openebs/dynamic-nfs-provisioner) helps developers run Kubernetes [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset), and provides fast and reliable [Container Attached Storage](https://openebs.io/docs/concepts/cas) support. The OpenEBS NFS implementation enables dynamic volume provisioning on top of the block storage of your cloud provider (e.g. [DigitalOcean Block Storage](https://www.digitalocean.com/products/block-storage)). Pods running on different nodes can access same data, thus you can use the [RWX access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for persistent volumes.

**Note:**

This stack requires a minimum configuration of 2 Nodes at the $10/month plan (2GB memory / 1 vCPU).

## OpenEBS Dynamic NFS Provisioner Overview Diagram

The following diagram shows how OpenEBS Dynamic NFS Provisioner works on a Kubernetes cluster in conjunction with a Wordpress deployment:

![OpenEBS Dynamic NFS Provisioner Overview](assets/images/arch_openebs.png)

## Software included

| Package | Application Version | Helm Chart Version | License |
| --------| ------------------- | ------------------ | ------- |
| OpenEBS Dynamic NFS provisioner | [0.9.0](https://github.com/openebs/dynamic-nfs-provisioner/tree/v0.9.0/deploy/helm/charts) | [0.9.0](https://github.com/openebs/dynamic-nfs-provisioner/releases/tag/nfs-provisioner-0.9.0) | [Apache 2.0](https://github.com/openebs/dynamic-nfs-provisioner/blob/develop/LICENSE) |

## Getting Started

### Connecting to Your Cluster

You can connect to your DigitalOcean Kubernetes cluster by following the official [how-to guide](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/).

For additional instructions on configuring a [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/) cluster, see the following [guide](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks).

### Confirming OpenEBS NFS Provisioner is Running

First, verify that the Helm installation was successful by running following command:

```bash
helm ls -n openebs-nfs-provisioner
```

If the installation was successful, the `STATUS` column value in the output reads `deployed`:

```text
NAME                    NAMESPACE               REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
openebs-nfs-provisioner openebs-nfs-provisioner 1               2022-05-17 10:08:02.345252 +0300 EEST   deployed        nfs-provisioner-0.9.0   0.9.0 
```

Next, verify that the `openebs-nfs-provisioner` Pod is up and running:

```console
kubectl get pods --all-namespaces -l name=openebs-nfs-provisioner
```

The output looks similar to:

```text
NAMESPACE                 NAME                                       READY   STATUS    RESTARTS   AGE
openebs-nfs-provisioner   openebs-nfs-provisioner-5cfd76f4fc-5k7wf   1/1     Running   0          11m
```

All Pod(s) should be in a `Running` state.

### Testing RWX Access Mode for OpenEBS NFS Volumes

To benefit from the OpenEBS NFS provisioner RWX functionality, you need to define a new storage class to dynamically provision NFS volumes on top of the DigitalOcean block storage (`do-block-storage`). Then, applications can use the new storage class for shared access of PVs.

Below example shows a typical definition for the OpenEBS NFS storage class:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-rwx-storage
  annotations: 
    openebs.io/cas-type: nsfrwx
    cas.openebs.io/config: |
      - name: NSFServerType
        value: "kernel"
      - name: BackendStorageClass
        value: "do-block-storage"
provisioner: openebs.io/nfsrwx
reclaimPolicy: Delete
```

Above configuration instructs OpenEBS to use `do-block-storage` as the `BackendStorageClass`, via the `cas.openebs.io/config` annotation.

**Note:**

You don't need to apply the above manifest by hand because it's already handled by the OpenEBS NFS Provisioner 1-click app.

Next, you will create a new PVC referencing the OpenEBS `nfs-rwx-storage` class:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  storageClassName: nfs-rwx-storage
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

Above manifest instructs Kubernetes to create a new PVC based on the `nfs-rwx-storage` class via `spec.storageClassName`, and sets access mode to `ReadWriteMany` (`spec.accessModes`). You can accomplish the above task by using the [sample manifest](assets/manifests/nfs-pvc.yaml) provided in the marketplace GitHub repository:

```shell
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/openebs-nfs-provisioner/assets/manifests/nfs-pvc.yaml
```

Now, check if the `nfs-pvc` is healthy:

```shell
kubectl get pvc nfs-pvc
```

The output looks similar to:

```text
NAME      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
nfs-pvc   Bound    pvc-776fd89f-c7aa-4e57-a8f5-914ab77f71d5   1Gi        RWX            nfs-rwx-storage  1m
```

The NFS PVC should be in a `Bound` state, and access mode set to `RWX` (ReadWriteMany). Storage class should display `nfs-rwx-storage`, and a capacity of `1Gi` should be provisioned.

Next, create the [nfs-share-test](assets/manifests/nfs-share-test.yaml) deployment provided in the marketplace GitHub repository:

```shell
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/openebs-nfs-provisioner/assets/manifests/nfs-share-test.yaml
```

Above manifest will create the `nfs-share-test` deployment with a replica count of 3, and mounts same volume (`nfs-share-test`) for all pods to consume. Then, the Kubernetes [Downward API]( https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information) is used to read each Pod metadata (such as Node name, Pod Name/IP), and write the details in a single log file from the NFS share (`/mnt/nfs-test/nfs-rwx.log`).

Now, inspect `nfs-share-test` deployment Pods status:

```shell
kubectl get pods -l test=nfs-share
```

The output looks similar to:

```text
NAME                              READY   STATUS    RESTARTS   AGE
nfs-share-test-67bf984f88-4flq2   1/1     Running   0          98s
nfs-share-test-67bf984f88-9hmfz   1/1     Running   0          98s
nfs-share-test-67bf984f88-tnz8q   1/1     Running   0          98s
```

All pods should be healthy and in a running state.

Finally, check `nfs-share-test` deployment logs:

```shell
kubectl exec -it deployments/nfs-share-test -- tail -f /mnt/nfs-test/nfs-rwx.log
```

The output looks similar to:

```text
...
[2022-05-31 11:09:04][NFS-RWX-TEST] NODE=basicnp-cajb7 POD=nfs-share-test-67bf984f88-9hmfz POD_IP=10.244.0.229
[2022-05-31 11:09:04][NFS-RWX-TEST] NODE=basicnp-cajbm POD=nfs-share-test-67bf984f88-4flq2 POD_IP=10.244.0.112
[2022-05-31 11:09:14][NFS-RWX-TEST] NODE=basicnp-cajb7 POD=nfs-share-test-67bf984f88-tnz8q POD_IP=10.244.0.243
[2022-05-31 11:09:14][NFS-RWX-TEST] NODE=basicnp-cajb7 POD=nfs-share-test-67bf984f88-9hmfz POD_IP=10.244.0.229
[2022-05-31 11:09:14][NFS-RWX-TEST] NODE=basicnp-cajbm POD=nfs-share-test-67bf984f88-4flq2 POD_IP=10.244.0.112
[2022-05-31 11:09:24][NFS-RWX-TEST] NODE=basicnp-cajb7 POD=nfs-share-test-67bf984f88-tnz8q POD_IP=10.244.0.243
...
```

Each pod should be able to write to the same log file (`nfs-rwx.log`), and publish its metadata each 10 seconds.

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

- [OpenEBS NFS Provisioner on GitHub](https://github.com/openebs/dynamic-nfs-provisioner)
- [Deploying Wordpress on DigitalOcean using OpenEBS NFS Provisioner](https://github.com/digitalocean/container-blueprints/tree/main/DOKS-wordpress)
- [Configuring Node Affinity for NFS Volumes](https://github.com/openebs/dynamic-nfs-provisioner/blob/develop/docs/tutorial/node-affinity.md)
- [Setting Resource requirements for NFS Server](https://github.com/openebs/dynamic-nfs-provisioner/blob/develop/docs/tutorial/configure-nfs-server-resource-requirements.md)
- [Exposing NFS Volume outside the cluster](https://github.com/openebs/dynamic-nfs-provisioner/blob/develop/docs/expose-nfs-server.md)
- [Monitoring NFS Provisioner](https://github.com/openebs/dynamic-nfs-provisioner/blob/develop/docs/metrics.md)
- [Configuring Hook for NFS Provisioner](https://github.com/openebs/dynamic-nfs-provisioner/blob/develop/docs/tutorial/nfs-hook.md)
