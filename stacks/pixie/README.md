# Pixie

Pixie is an open source observability tool for Kubernetes applications. Use Pixie to view the high-level state of your cluster (service maps, cluster resources, application traffic) and also drill-down into more detailed views (pod state, flame graphs, individual full-body application requests).

Three features enable Pixie's magical developer experience:

- **Auto-telemetry:** Pixie uses eBPF to automatically collect telemetry data such as full-body requests, resource and network metrics, application profiles, and more. See the full list of data sources [here](https://docs.px.dev/about-pixie/data-sources/).

- **In-Cluster Edge Compute:** Pixie collects, stores and queries all telemetry data locally in the cluster. Pixie uses less than 5% of cluster CPU, and in most cases less than 2%.

- **Scriptability:** [PxL](https://docs.px.dev/reference/pxl/), Pixie’s flexible Pythonic query language, can be used across Pixie’s UI, CLI, and client APIs.

## Prerequisites

You must have either:

- You need to have a Pixie account and deployment key on [Community Cloud for Pixie](https://withpixie.ai).
- Or a Pixie account and deployment key on a [self-hosted Pixie Cloud](https://docs.px.dev/installing-pixie/install-guides/self-hosted-pixie/).

## Getting Started

### Deploying

1. From the Pixie Cloud UI. Go to Admin > Deployment Keys > New Key. If using [Pixie's CLI](https://docs.px.dev/using-pixie/using-cli/), run `px api-key create`.
2. Update `deployKey` in `values.yml` with the deployKey from above.
3. Run `deploy.sh`. 

## Additional Resources

- [Documentation](https://docs.px.dev)
- [Github repo](https://github.com/pixie-io/pixie)
- [Slack](https://slackin.px.dev/)
