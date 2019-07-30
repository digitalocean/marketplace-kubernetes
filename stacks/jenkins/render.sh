#!/bin/sh

set -e

BUILD_DIR=$(mktemp -d)
ROOT_DIR=$(git rev-parse --show-toplevel)

JENKINS_CHART_VERSION="1.4.1"

cp -r "$ROOT_DIR"/src/jenkins/"$JENKINS_CHART_VERSION" $BUILD_DIR
cp -r "$ROOT_DIR"/stacks/jenkins $BUILD_DIR

cd $BUILD_DIR

# Remove test templates
find "$JENKINS_CHART_VERSION" -type d -name tests -print0 | xargs -0 rm -rf

# Create YAML directory
rm -rf "$ROOT_DIR"/stacks/jenkins/yaml
mkdir -p "$ROOT_DIR"/stacks/jenkins/yaml

# render jenkins
helm template \
  --name jenkins \
  --namespace jenkins \
  --values jenkins/values/jenkins.yaml \
  "$JENKINS_CHART_VERSION" > "$ROOT_DIR"/stacks/jenkins/yaml/jenkins.yaml
