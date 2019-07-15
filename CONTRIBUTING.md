# Contributing

When adding your application to the [digitalocean/marketplace-kubernetes](https://github.com/digitalocean/marketplace-kubernetes) repository, you’ll need
to make modifications within 2 directories: **src** and **stacks**. **src** will
contain the Helm template or raw YAML for your application. **stacks** will contain
the rendered YAML manifest and deployment scripts necessary to deploy your application
onto a Kubernetes cluster. You can customize your rendered manifest by specifying
custom Helm values (if applicable), kustomize, or a combination of both.

## Adding Your Application

### Step 1: add your application to src

1. Clone the [digitalocean/marketplace-kubernetes](https://github.com/digitalocean/marketplace-kubernetes) repository
2. Create a branch for your application
3. If you’re application is deployed using Helm:

```bash
# create a new directory for your application in src
mkdir src/$APP_NAME
cd src/$APP_NAME
helm fetch --version $HELM_CHART_VERSION --untar $HELM_CHART_NAME
mv $APP_NAME $HELM_CHART_VERSION
# commit your changes
```

If you’re application is deployed via raw YAML:

```bash
# create a new directory for your application in src
mkdir src/$APP_NAME
cd src/$APP_NAME
mkdir $VERSION
# add your YAML files to src/$APP_NAME/$VERSION
# commit your changes
```

### Step 2: create your application stack

1. Run `STACK_NAME=$APP_NAME ./generate-stack.sh` to generate the files necessary to render and deploy your application. They will be located in `stacks/$APP_NAME`.
2. Modify the generated files so that they work best for your application.
3. Render the YAML used to deploy your application by running: `./stacks/$APP_NAME/render.sh`. Whenever you add a new version to `src`, you should
re-render the YAML so that your stack always points to the latest version of your application.
4. To ensure that the rendered YAML works as expected, deploy it to a test Kubernetes cluster by running: `./stacks/$APP_NAME/deploy-local.sh`
5. Once everything looks good, commit your changes and open a PR.

## How to deploy your application in production

At DigitalOcean, we have a service dedicated to deploying stacks onto clusters. This is accomplished
by simply CURLing a specific `deploy.sh` file, and piping it to `sh`. For example, if you wanted to deploy
the [monitoring](https://github.com/digitalocean/marketplace-kubernetes/tree/master/stacks/monitoring) stack from your local machine onto a cluster you manager, you could run the rollowing:

```bash
curl --location --silent --show-error \
  https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/monitoring/deploy.sh | sh
```
