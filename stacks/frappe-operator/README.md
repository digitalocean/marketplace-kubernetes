# Operator for ERPNext, CRM, HRMS & the Frappe App Ecosystem by Vyogo (DigitalOcean 1-Click)

The **Operator for ERPNext, CRM, HRMS & the Frappe App Ecosystem**, developed by **[Vyogo Technologies](https://vyogo.tech)**, enables you to deploy open-source Frappe Framework and business apps — including ERPNext, CRM, HRMS, and custom apps — in a completely declarative way on DigitalOcean Kubernetes. Powered by the FPM (Frappe Package Manager) catalog ([fpm.vyogo.tech](https://fpm.vyogo.tech)), the operator can install any cataloged app in a flash without the overhead of building or maintaining custom container images for every combination. Describe a bench and its sites in YAML, and Vyogo's operator automatically provisions databases, runs migrations, takes backups, manages multi-node RWX storage, and automates ingress routing.

> **Looking for managed hosting?** If you prefer a fully managed cloud solution without managing Kubernetes clusters, visit **[console.vyogo.cloud](https://console.vyogo.cloud)**.

It natively supports both **MariaDB** and **PostgreSQL** database engines out of the box.

## Prerequisites

1. **Helm 3** and `kubectl` on your local machine.
2. **A DigitalOcean Kubernetes cluster**, with kubeconfig configured.
3. **At least two nodes with 2 GB+ RAM** (or one 4 GB+ node).

## What gets installed

- **Frappe Operator** in `frappe-operator-system` namespace.
- **MariaDB Operator**, for automatic provisioning of MariaDB site databases (Frappe's primary database engine).
- **KEDA**, for event-driven autoscaling of Frappe workers.
- **NGINX Ingress Controller**, pre-wired to the operator for HTTP/HTTPS routing to sites.
- **OpenEBS Dynamic NFS Provisioner**, exposing the `nfs-rwx-storage` StorageClass for ReadWriteMany (RWX) multi-replica benches.

No bench or site is created during install. You create your first bench after install.

## Databases

Frappe Framework supports **MariaDB** and **PostgreSQL** (MySQL is not supported).

| Engine | Mode | Provisioner |
|---|---|---|
| **MariaDB** (default) | shared or dedicated | MariaDB Operator (bundled subchart) or External MariaDB |
| **PostgreSQL** | shared | DigitalOcean Managed PostgreSQL (or external PostgreSQL) |
| **PostgreSQL** | dedicated | StackGres / Percona Operator (opt-in) |

### Example 1: FrappeSite with MariaDB (Default)

MariaDB databases and users are provisioned automatically by the bundled MariaDB Operator:

```yaml
apiVersion: vyogo.tech/v1
kind: FrappeBench
metadata:
  name: mariadb-bench
  namespace: default
spec:
  frappeVersion: "version-16"
  storageClassName: "nfs-rwx-storage"
  apps:
    - name: erpnext
      source: image
---
apiVersion: vyogo.tech/v1
kind: FrappeSite
metadata:
  name: site1-local
  namespace: default
spec:
  benchRef:
    name: mariadb-bench
  siteName: site1.local
  dbConfig:
    provider: mariadb
    mode: shared
```

### Example 2: FrappeSite with DigitalOcean Managed PostgreSQL

When using DigitalOcean Managed PostgreSQL, Frappe Operator provisions the site database and role automatically via a lightweight Kubernetes batch Job using your cluster's connection credentials, without requiring in-cluster database operators:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: do-postgres-creds
  namespace: default
type: Opaque
stringData:
  user: doadmin
  password: "<YOUR_MANAGED_PG_PASSWORD>"
---
apiVersion: vyogo.tech/v1
kind: FrappeSite
metadata:
  name: pg-site-local
  namespace: default
spec:
  benchRef:
    name: pg-bench
  siteName: pgsite.local
  dbConfig:
    provider: postgres
    mode: shared
    host: "db-postgresql-nyc1-12345-do-user-12345-0.b.db.ondigitalocean.com"
    port: "25060"
    postgresRef:
      name: do-postgres-creds
```

### Example 3: Dedicated PostgreSQL via StackGres (Post-Deploy Installation)

If you require per-site dedicated PostgreSQL clusters running directly inside your Kubernetes cluster instead of managed databases, you can install the **StackGres Operator** at any time after the 1-Click deploy.

#### 1. Install StackGres Operator

```bash
helm repo add stackgres https://stackgres.io/downloads/stackgres-k8s/stackgres/helm
helm repo update

helm upgrade --install stackgres-operator stackgres/stackgres-operator \
  --namespace stackgres \
  --create-namespace \
  --wait
```

#### 2. Reconfiguring Frappe Operator

- **RBAC & Discovery**: Frappe Operator's ClusterRole is already pre-configured with full permissions for StackGres custom resources (`sgclusters.stackgres.io`, `sginstanceprofiles`, `sgpgconfigs`, `sgpoolconfigs`, `sgscripts`). The operator uses dynamic client resolution to discover StackGres automatically once installed.
- **Refresh Discovery (Recommended)**: To immediately refresh the Kubernetes API discovery cache on the running operator:
  ```bash
  kubectl rollout restart deployment/frappe-operator-controller-manager -n frappe-operator-system
  ```
- **Optional - Disable MariaDB Operator**: If you are only using PostgreSQL and want to free up cluster resources (RAM/CPU) by turning off the bundled MariaDB Operator:
  ```bash
  helm upgrade frappe-operator frappe-operator/frappe-operator \
    --namespace frappe-operator-system \
    --reuse-values \
    --set mariadb-operator.enabled=false
  ```

#### 3. Deploy a Dedicated PostgreSQL Site

> **Note**: Frappe PostgreSQL support is available on Frappe develop / v17 branch. Ensure your bench image supports Postgres.

```yaml
apiVersion: vyogo.tech/v1
kind: FrappeBench
metadata:
  name: pg-bench
  namespace: default
spec:
  frappeVersion: "develop"
  storageClassName: "nfs-rwx-storage"
  apps:
    - name: erpnext
      source: image
---
apiVersion: vyogo.tech/v1
kind: FrappeSite
metadata:
  name: pg-dedicated-site
  namespace: default
spec:
  benchRef:
    name: pg-bench
  siteName: pgsite.local
  dbConfig:
    provider: postgres
    mode: dedicated
    postgresEngine: stackgres
```

The Frappe Operator will automatically provision an `SGCluster` and database user via StackGres for this site.

## Storage (ReadWriteMany / RWX)

DigitalOcean's default block storage (`do-block-storage`) is ReadWriteOnce (RWO). For multi-replica benches, specify:

```yaml
spec:
  storageClassName: nfs-rwx-storage
```

This uses the bundled OpenEBS dynamic NFS provisioner to create RWX volumes backed by DO block storage.

## Installation

Run `deploy.sh`, which is equivalent to:

```bash
helm repo add frappe-operator https://vyogotech.github.io/frappe-operator/helm-repo
helm repo update

helm upgrade frappe-operator frappe-operator/frappe-operator \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace frappe-operator-system \
  --values values.yml
```

Verify:

```bash
kubectl get pods -n frappe-operator-system
kubectl get storageclass
```

## Upgrading and uninstalling

Run `upgrade.sh` to move to a newer chart version, and `uninstall.sh` to remove the
release. Database data and CRDs are preserved on uninstall.

## About Vyogo Technologies & Managed Hosting

The Frappe & ERPNext Operator is designed, engineered, and maintained by **[Vyogo Technologies](https://vyogo.tech)**. It is an independent enterprise Kubernetes operator for running Frappe Framework, ERPNext, CRM, HRMS, and custom Frappe applications at scale in production environments.

- **Managed Cloud**: For fully managed hosting with automated backups, scaling, and zero-maintenance operations, visit **[console.vyogo.cloud](https://console.vyogo.cloud)**.
- **App Catalog**: Browse hundreds of supported apps at **[fpm.vyogo.tech](https://fpm.vyogo.tech)**.

*Notice: Frappe Framework and ERPNext are open-source trademarks of Frappe Technologies Pvt. Ltd. This operator is an independent product developed and maintained by Vyogo Technologies and is not affiliated with or endorsed by Frappe Technologies.*

## License and support

The Frappe & ERPNext Operator by Vyogo Technologies is licensed under the [Elastic License 2.0](https://github.com/vyogotech/frappe-operator/blob/release/LICENSE).
- Managed Cloud: https://console.vyogo.cloud
- App Catalog: https://fpm.vyogo.tech
- Website: https://vyogo.tech
- GitHub: https://github.com/vyogotech/frappe-operator
- Documentation: https://vyogotech.github.io/frappe-operator/
- Support: support@vyogo.tech
