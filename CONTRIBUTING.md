# Contributing

**Requirement: Your application must be deployable via Helm 3**

To add your application to the [DigitalOcean Marketplace](https://marketplace.digitalocean.com/), you'll need to do the following:
1. Ensure that you have Helm 3 installed on your machine. [Instructions](https://helm.sh/docs/intro/install/)
1. Add the Helm 3 deployment (`deploy.sh`), upgrade (`upgrade.sh`) and uninstall (`uninstall.sh`) files to this repo.
1. Get an account set up within the [DigitalOcean Marketplace Vendor Portal](https://marketplace.digitalocean.com/vendorportal)

## Adding Your Application
1. Clone or fork the [digitalocean/marketplace-kubernetes](https://github.com/digitalocean/marketplace-kubernetes) repository
1. Create a git branch that includes the name of your app (example: `$APP_NAME-first-pr`)
1. Run the following commands to create your `deploy.sh`, `upgrade.sh`, `uninstall.sh` and `values.yml` files. They will be located in `stacks/$APP_NAME`:
```bash
export HELM_REPO_NAME=stable
export HELM_REPO_URL=https://charts.helm.sh/stable
export STACK_NAME=$APP_NAME
export CHART_NAME=$APP_NAME/$APP_NAME
export CHART_VERSION=1.0.0
export NAMESPACE=$APP_NAME

./utils/generate-stack.sh
```
6. Optionally, customize your `deploy.sh`, `upgrade.sh`, `uninstall.sh` and specify your Helm chart's configuration values in `values.yml`. Both can be found in `stacks/$APP_NAME`
7. Test out installing your stack by deploying it locally to a k8s cluster: `./stacks/$APP_NAME/deploy.sh`
8. Test out upgrading your stack by updating it locally on a k8s cluster: `./stacks/$APP_NAME/upgrade.sh`
9. Test out uninstalling your stack by deleting it locally from a k8s cluster: `./stacks/$APP_NAME/uninstall.sh`
10. Open a PR
11. Once the PR is reviewed and merged by DigitalOcean, visit the [DigitalOcean Marketplace Vendor Portal](https://marketplace.digitalocean.com/vendorportal) and submit your App Listing, refering to this PR in the appropriate input field.

## Updating Your Application
1. To deploy a newer version of your app's Helm chart, simply update the `CHART_VERSION` value in your `stacks/$APP_NAME/deploy.sh` file. If necessary, update your `values.yml` as well.
1. Open a PR
1. Once your PR is merged, make any needed updates in the [Vendor Portal](https://marketplace.digitalocean.com/vendorportal) to your App Listing, including referring to the URL of the PR that was merged. **Your new PR will not take effect until you do this final step in the Vendor Portal.**

## Getting Vendor Portal Access

Email one-clicks-team@digitalocean.com to get access to the Marketplace Vendor Portal. This is where you will manage your application's listing page.
