# Description

[StackRadar](https://stackradar.io) shows the vulnerabilities on the images
running in your Kubernetes cluster, ranked by what to fix first, with the
upgrade that fixes them.

A scanner tells you your cluster has four thousand CVEs. StackRadar tells you
which of them are on images that are running right now, which of those are
being exploited in the wild, and which chart version or image tag makes them
go away. When a new advisory is published, the dashboard already knows which
pods run it, without pulling or scanning anything again.

This 1-Click installs StackRadar Community Edition into the `stackradar`
namespace: the server, the web UI, a bundled PostgreSQL and the scanner,
already scanning the cluster it lands in.

- **Scans what runs, once.** A read-only agent watches the pods of the
  cluster, pulls each image once per digest and writes its SBOM with
  [Syft](https://github.com/anchore/syft). No scan Job per workload, no
  report objects in etcd.
- **Re-matches instead of re-scanning.** The server mirrors
  [OSV.dev](https://osv.dev), [EPSS](https://www.first.org/epss/) and the
  [CISA KEV catalogue](https://www.cisa.gov/known-exploited-vulnerabilities-catalog)
  locally and matches every stored SBOM again whenever the mirror changes.
- **Ranks by exploitability.** The Radar Score folds CVSS, EPSS and KEV into
  one number per finding and sums them per image, container, release and
  cluster. The top of every list is what to fix first.
- **Tells base image from application layer**, so a finding in your own
  code is not buried under the ones in `debian:bookworm`.
- **Knows how the image got there.** The Helm release that packaged a
  workload and the Argo CD application that delivers it are on the page, so
  the fix is a chart version and a `helm`, `argocd` or `kubectl` command.
- **End-of-life verdicts** for base images, so a fix that cannot exist is
  not on the list.
- **One Postgres, migrations on boot, no telemetry.** Nothing leaves the
  cluster except the advisory feed downloads.

This 1-Click generates every secret at install time (session signing key,
scanner key, database password), so no two installs share a credential.

**Sizing.** The chart requests about 0.6 vCPU and 2 GiB of memory in total
and creates one 10 GiB block storage volume for PostgreSQL. A single
2 vCPU / 4 GB node runs it for evaluation; for a cluster with hundreds of
distinct images, give the server pod room to grow to its 2 GiB limit and
use a node pool of 2 vCPU / 4 GB nodes or larger. The first start downloads
about 1.2 GB of compressed OSV data in the background; findings appear as
that mirror comes alive, typically within 5 to 25 minutes.

StackRadar is open source under AGPL-3.0. Thank you to all the contributors
whose hard work makes this software valuable for users, and to the Syft,
OSV.dev, FIRST and CISA projects it is built on.

## Software Included

| Package | Version | License |
|---------|---------|---------|
| StackRadar server and UI | [0.2.0](https://github.com/lockdep/stackradar/releases/tag/v0.2.0) | [AGPL-3.0](https://github.com/lockdep/stackradar/blob/main/LICENSE) |
| StackRadar scanner | [0.7.1](https://github.com/lockdep/stackradar-scanner/releases/tag/v0.7.1) | [Apache-2.0](https://github.com/lockdep/stackradar-scanner/blob/main/LICENSE) |
| PostgreSQL | [18 (alpine)](https://hub.docker.com/_/postgres) | [PostgreSQL License](https://www.postgresql.org/about/licence/) |
| Helm chart `stackradar` | [0.2.1](https://github.com/lockdep/helm-charts/tree/main/charts/stackradar) | [Apache-2.0](https://github.com/lockdep/helm-charts/blob/main/LICENSE) |

# Getting Started

### Getting Started with DigitalOcean Kubernetes

As you get started with Kubernetes on DigitalOcean be sure to check out how
to connect to your cluster using `kubectl` and `doctl`:
https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/

Additional instructions are included in the DigitalOcean Kubernetes control
panel: https://cloud.digitalocean.com/kubernetes/clusters/

### Confirm StackRadar is running

```console
kubectl get pods -n stackradar
```

The output looks similar to the following (names after the dash vary):

```text
NAME                                          READY   STATUS    RESTARTS   AGE
stackradar-client-6d5b85476c-nf445            1/1     Running   0          3m
stackradar-postgresql-0                       1/1     Running   0          3m
stackradar-scanner-watcher-7c45798d44-rxhnq   1/1     Running   0          3m
stackradar-server-677f58bd99-fx47c            1/1     Running   0          3m
```

All four pods should be `Running` and `1/1` ready. The server and the UI
apply their own database migrations at start-up, so the first start can
take a minute longer than the others.

### Open the dashboard

The UI is not exposed outside the cluster by default. Forward it to your
machine:

```console
kubectl -n stackradar port-forward svc/stackradar-client 3000:3000
```

Open http://localhost:3000 and sign in with

| | |
|---|---|
| Email | `admin@stackradar.local` |
| Password | `admin` |

You are asked to change the password before anything else loads. Do it.

A yellow strip above every page says **Vulnerability database is being
built** while the server downloads and imports OSV, EPSS and KEV in the
background. Meanwhile the scanner has already swept the cluster: the
Containers and Images pages fill with what is running, and findings appear
on each image as the mirror goes live. Nothing to do; the strip goes away on
its own.

The scanner skips `kube-system`, `kube-public` and `kube-node-lease` by
default, so on a fresh DOKS cluster the first inventory is StackRadar
itself. To include the system namespaces (CoreDNS, Cilium, the CSI
drivers), clear the exclusion list and upgrade the release:

```console
helm upgrade stackradar oci://ghcr.io/lockdep/helm-charts/stackradar --version 0.2.1 \
  --namespace stackradar --reuse-values --set scanner.scanner.excludeNamespaces=""
```

### Reach it from outside (optional)

For a hostname instead of a port-forward, enable the chart's Ingress or
Gateway API `HTTPRoute` with your own values and upgrade the release; the
[self-hosting guide](https://github.com/lockdep/stackradar/blob/main/docs/self-hosting/helm.md)
walks through Ingress, TLS and sign-in with GitHub, Google or any OpenID
Connect provider. Change the admin password before exposing the install
beyond localhost.

### Tweaking Helm chart values

The stack installs the chart's defaults plus the generated secrets. Inspect
every available option with

```console
helm show values oci://ghcr.io/lockdep/helm-charts/stackradar --version 0.2.1
```

and apply your own values with `--reuse-values`, which keeps the generated
secrets:

```console
helm upgrade stackradar oci://ghcr.io/lockdep/helm-charts/stackradar --version 0.2.1 \
  --namespace stackradar --reuse-values --values my-values.yml
```

### Scan more clusters

Community Edition shows one cluster per dashboard: the one it runs in. The
hosted version at [app.stackradar.io](https://app.stackradar.io) shows many;
the same scanner chart reports to either.

### Uninstall

```console
helm uninstall stackradar -n stackradar
```

The PostgreSQL volume is kept so an uninstall is not a data loss, and so is
the `stackradar` ServiceAccount; nothing cluster-scoped is left behind. To
remove both: `kubectl delete namespace stackradar`.

### Additional Resources

- Documentation: https://github.com/lockdep/stackradar/tree/main/docs
- Chart values reference: https://github.com/lockdep/helm-charts/blob/main/charts/stackradar/README.md
- Chart upgrade notes: https://github.com/lockdep/helm-charts/blob/main/charts/stackradar/UPGRADING.md
- Live demo: https://demo.stackradar.io/demo/enter
- Issues and support: https://github.com/lockdep/stackradar/issues
