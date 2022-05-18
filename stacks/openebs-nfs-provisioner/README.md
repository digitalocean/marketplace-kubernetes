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

You will configure the default Kubernetes Storage Class (do-block-storage) provided by DigitalOcean as the backend storage for the NFS provisioner. In that case, whichever application uses the newly created Storage Class, can consume shared storage (NFS) on a DigitalOcean volume using OpenEBS NFS provisioner.

Create a YAML file `sc-rwx.yaml`:

```yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: rwx-storage
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

Explanations for the above configuration:

- `provisioner` - defines what storage class is used for provisioning PVs (e.g. openebs.io/nfsrwx)
- `reclaimPolicy` - dynamically provisioned volumes are automatically deleted when a user deletes the corresponding PersistentVolumeClaim

Apply via kubectl:

```console
kubectl apply -f assets/manifests/sc-rwx.yaml
```

Verify that the StorageClass was created by executing the command below:

```console
kubectl get sc
```

The ouput looks similar to:

```text
NAME                         PROVISIONER                 RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
do-block-storage (default)   dobs.csi.digitalocean.com   Delete          Immediate           true                   107m
openebs-kernel-nfs           openebs.io/nfsrwx           Delete          Immediate           false                  84m
rwx-storage                  openebs.io/nfsrwx           Delete          Immediate           false                  84m
```

Now, you have a new StorageClass named rwx-storage to dynamically provision shared volumes on top of DigitalOcean Block Storage.

When enabling persistance for a Wordpress installation the storage class created above should be set.

A typical Wordpress manifest:

```yaml
# WordPress service type
service:
  type: ClusterIP

# Enable persistence using Persistent Volume Claims
persistence:
  enabled: true
  storageClassName: rwx-storage
  accessModes: ["ReadWriteMany"]
  size: 5Gi

volumePermissions:
  enabled: true

replicaCount: 3

# Prometheus Exporter / Metrics configuration
metrics:
  enabled: false

# Level of auto-updates to allow. Allowed values: major, minor or none.
wordpressAutoUpdateLevel: minor

# Scheme to use to generate WordPress URLs
wordpressScheme: https

# WordPress credentials
wordpressUsername: <YOUR_WORDPRESS_USER_NAME_HERE>
wordpressPassword: <YOUR_WORDPRESS_USER_PASSSWORD_HERE>

# External Database details
externalDatabase:
  host: <YOUR_WORDPRESS_MYSQL_DB_HOST_HERE>
  port: 25060
  user: <YOUR_WORDPRESS_MYSQL_DB_USER_NAME_HERE>
  password: <YOUR_WORDPRESS_MYSQL_DB_USER_PASSWORD_HERE>
  database: <YOUR_WORDPRESS_MYSQL_DB_NAME_HERE>

# Disabling MariaDB
mariadb:
  enabled: false
```

After Wordpress would be installed you can check the PVCs created under the wordpress namespace, and associated OpenEBS volume under the openebs namespace:

```console
kubectl get pvc -A
```

The output looks similar to (notice the `RWX` access mode for the wordpress PVC, and the new storage class defined earlier via the openEBS NFS provisioner):

```text
NAMESPACE   NAME                                           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       AGE
openebs     nfs-pvc-b505c0af-e6ab-4623-8ad1-1bad784261d5   Bound    pvc-d3f0c597-69ba-4710-bd7d-ed29ce41ce04   5Gi        RWO            do-block-storage   20m
wordpress   wordpress                                      Bound    pvc-b505c0af-e6ab-4623-8ad1-1bad784261d5   5Gi        RWX            rwx-storage        20m
```

Verify the associated PVs created in the cluster:

```console
kubectl get pv
```

The ouput looks similar to:

```text
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                  STORAGECLASS       REASON   AGE
pvc-b505c0af-e6ab-4623-8ad1-1bad784261d5   5Gi        RWX            Delete           Bound    wordpress/wordpress                                    rwx-storage                 23m
pvc-d3f0c597-69ba-4710-bd7d-ed29ce41ce04   5Gi        RWO            Delete           Bound    openebs/nfs-pvc-b505c0af-e6ab-4623-8ad1-1bad784261d5   do-block-storage            23m
```

**Note:**
For more information on this setup please visit this [container-blueprint](https://github.com/digitalocean/container-blueprints/tree/main/DOKS-wordpress)

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

- [Documentation](https://openebs.io/docs)
- [OpenEBS Community Resources](https://openebs.io/community)
- [FAQ](https://openebs.io/faq)
