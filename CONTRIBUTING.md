# Contributing

To add your Kubernetes application to the [DigitalOcean Marketplace](https://marketplace.digitalocean.com/), you'll need to do the following:
1. Ensure that you have Helm 3 installed on your machine. [Instructions](https://helm.sh/docs/intro/install/)
1. Add a Helm 3 deployment (`deploy.sh`) file to this repo.
1. Get an account set up within the [DigitalOcean Marketplace Vendor Portal](https://marketplace.digitalocean.com/vendorportal)

Note: We strongly advise that you utilize Helm for deploying your app. If this isn't possible, please reach out to us at one-clicks-team@digitalocean.com.

## Adding Your Application
1. Clone or fork the [digitalocean/marketplace-kubernetes](https://github.com/digitalocean/marketplace-kubernetes) repository
1. Create a git branch that includes the name of your app (example: `$APP_NAME-first-pr`)
1. Run the following commands to create your `deploy.sh` and `values.yml` files. They will be located in `stacks/$APP_NAME`:
```bash
export HELM_REPO_NAME=stable
export HELM_REPO_URL=https://kubernetes-charts.storage.googleapis.com/
export STACK_NAME=$APP_NAME
export CHART_NAME=$APP_NAME/$APP_NAME
export CHART_VERSION=1.0.0
export NAMESPACE=$APP_NAME

./utils/generate-stack.sh
```
4. Optionally, customize your `deploy.sh` and specify your Helm chart's configuration values in `values.yml`. Both can be found in `stacks/$APP_NAME`
4. Test out your stack by deploying it locally to a k8s cluster: `./stacks/$APP_NAME/deploy.sh`
4. Open a PR

## Updating Your Application
1. To deploy a newer version of your app's Helm chart, simply update the `CHART_VERSION` value in your `stacks/$APP_NAME/deploy.sh` file. If necessary, update your `values.yml` as well.
1. Open a PR
1. Once your PR is merged, make the necessary listing copy updates in the [Vendor Portal](https://marketplace.digitalocean.com/vendorportal). The changes you make there will be reflected within your Marketplace listing.

## Getting Vendor Portal Access

Email one-clicks-team@digitalocean.com to get access to the Marketplace Vendor Portal. This is where you will manage your application's listing page.
