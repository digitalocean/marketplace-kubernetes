#!/bin/sh

set -e

# Set pygluu-kubernetes.pyz version
PYGLUU_KUBERNETES_VERSION="v1.0.4"

# Set Gluu version
GLUU_VERSION='"'"4.1"'"'

# Create directory for installation files
mkdir gluu-cloud-native-edition
cd gluu-cloud-native-edition

# Generate random password for Gluu Admin, LDAP, postgres, Gluu Gateway datebases and UI
MASTER_PW_RAND="$(cat /dev/urandom \
      | env LC_CTYPE=C tr -dc 'a-zA-Z0-9A-Za-z0-9' \
      | fold -w 6 | head -c 6)"GluU4#
MASTER_PW_RAND='"'"$MASTER_PW_RAND"'"'

# Generate random string for oxd-server
OXD_SERVER_PW_RAND="$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)"
OXD_SERVER_PW_RAND='"'"$OXD_SERVER_PW_RAND"'"'

# Determine OS
if [ "$(uname -s)" = "Darwin" ]; then
  OS=osx
else
  OS=linux
fi

# Set python-package name
FILENAME="pygluu-kubernetes-$OS.pyz"
URL="https://github.com/GluuFederation/cloud-native-edition/releases/download/$PYGLUU_KUBERNETES_VERSION/$FILENAME"
PYTHON_PACKAGE="$FILENAME"

# Download Gluu cloud native edition installer
wget -q $URL -O "$PYTHON_PACKAGE" && chmod +x "$PYTHON_PACKAGE"

# Create installation parameters in settings.json for a non-interactive setup
cat <<EOF > settings.json
{
  "ACCEPT_GLUU_LICENSE": "Y",
  "GLUU_VERSION": $GLUU_VERSION,
  "GLUU_UPGRADE_TARGET_VERSION": "",
  "GLUU_HELM_RELEASE_NAME": "gluu",
  "NGINX_INGRESS_RELEASE_NAME": "ingress-nginx",
  "NGINX_INGRESS_NAMESPACE": "ningress",
  "INSTALL_GLUU_GATEWAY": "Y",
  "POSTGRES_NAMESPACE": "postgres",
  "KONG_NAMESPACE": "gluu-gateway",
  "GLUU_GATEWAY_UI_NAMESPACE": "gg-ui",
  "KONG_PG_USER": "kong",
  "KONG_PG_PASSWORD": $MASTER_PW_RAND,
  "GLUU_GATEWAY_UI_PG_USER": "konga",
  "GLUU_GATEWAY_UI_PG_PASSWORD": $MASTER_PW_RAND,
  "KONG_DATABASE": "kong",
  "GLUU_GATEWAY_UI_DATABASE": "konga",
  "POSTGRES_REPLICAS": 3,
  "POSTGRES_URL": "postgres.postgres.svc.cluster.local",
  "KONG_HELM_RELEASE_NAME": "gg",
  "GLUU_GATEWAY_UI_HELM_RELEASE_NAME": "ggui",
  "NODES_IPS": [],
  "NODES_ZONES": [],
  "NODES_NAMES": [],
  "NODE_SSH_KEY": "~/.ssh/id_rsa",
  "HOST_EXT_IP": "22.22.22.22",
  "VERIFY_EXT_IP": "",
  "AWS_LB_TYPE": "",
  "USE_ARN": "",
  "ARN_AWS_IAM": "",
  "LB_ADD": "",
  "REDIS_URL": "",
  "REDIS_TYPE": "",
  "REDIS_PW": "",
  "REDIS_USE_SSL": "false",
  "REDIS_SSL_TRUSTSTORE": "",
  "REDIS_SENTINEL_GROUP": "",
  "REDIS_MASTER_NODES": "",
  "REDIS_NODES_PER_MASTER": "",
  "REDIS_NAMESPACE": "",
  "INSTALL_REDIS": "",
  "INSTALL_JACKRABBIT": "Y",
  "JACKRABBIT_STORAGE_SIZE": "4Gi",
  "JACKRABBIT_URL": "http://jackrabbit:8080",
  "JACKRABBIT_USER": "admin",
  "DEPLOYMENT_ARCH": "do",
  "PERSISTENCE_BACKEND": "ldap",
  "INSTALL_COUCHBASE": "N",
  "COUCHBASE_NAMESPACE": "cbns",
  "COUCHBASE_VOLUME_TYPE": "pd-standard",
  "COUCHBASE_CLUSTER_NAME": "cbgluu",
  "COUCHBASE_FQDN": "*.cbns.svc.cluster.local",
  "COUCHBASE_URL": "cbgluu.cbns.svc.cluster.local",
  "COUCHBASE_USER": "admin",
  "COUCHBASE_PASSWORD": $MASTER_PW_RAND,
  "COUCHBASE_CRT": "",
  "COUCHBASE_CN": "Couchbase CN",
  "COUCHBASE_SUBJECT_ALT_NAME": "",
  "COUCHBASE_CLUSTER_FILE_OVERRIDE": "N",
  "COUCHBASE_USE_LOW_RESOURCES": "Y",
  "COUCHBASE_DATA_NODES": "",
  "COUCHBASE_QUERY_NODES": "",
  "COUCHBASE_INDEX_NODES": "",
  "COUCHBASE_SEARCH_EVENTING_ANALYTICS_NODES": "",
  "COUCHBASE_GENERAL_STORAGE": "",
  "COUCHBASE_DATA_STORAGE": "",
  "COUCHBASE_INDEX_STORAGE": "",
  "COUCHBASE_QUERY_STORAGE": "",
  "COUCHBASE_ANALYTICS_STORAGE": "",
  "COUCHBASE_BACKUP_SCHEDULE": "",
  "COUCHBASE_BACKUP_RESTORE_POINTS": "",
  "LDAP_BACKUP_SCHEDULE": "*/30 * * * *",
  "NUMBER_OF_EXPECTED_USERS": "",
  "EXPECTED_TRANSACTIONS_PER_SEC": "",
  "USING_CODE_FLOW": "",
  "USING_SCIM_FLOW": "",
  "USING_RESOURCE_OWNER_PASSWORD_CRED_GRANT_FLOW": "",
  "DEPLOY_MULTI_CLUSTER": "",
  "HYBRID_LDAP_HELD_DATA": "",
  "LDAP_VOLUME": "",
  "APP_VOLUME_TYPE": 22,
  "LDAP_STATIC_VOLUME_ID": "",
  "LDAP_STATIC_DISK_URI": "",
  "GLUU_CACHE_TYPE": "NATIVE_PERSISTENCE",
  "GLUU_NAMESPACE": "gluu",
  "GLUU_FQDN": "demoexample.gluu.org",
  "COUNTRY_CODE": "US",
  "STATE": "TX",
  "EMAIL": "support@gluu.org",
  "CITY": "Austin",
  "ORG_NAME": "Gluu",
  "GMAIL_ACCOUNT": "",
  "GOOGLE_NODE_HOME_DIR": "",
  "IS_GLUU_FQDN_REGISTERED": "N",
  "LDAP_PW": $MASTER_PW_RAND,
  "ADMIN_PW": $MASTER_PW_RAND,
  "OXD_SERVER_PW": $OXD_SERVER_PW_RAND,
  "OXD_APPLICATION_KEYSTORE_CN": "oxd-server",
  "OXD_ADMIN_KEYSTORE_CN": "oxd-server",
  "LDAP_STORAGE_SIZE": "4Gi",
  "OXAUTH_REPLICAS": 1,
  "OXTRUST_REPLICAS": 1,
  "LDAP_REPLICAS": 1,
  "OXSHIBBOLETH_REPLICAS": 1,
  "OXPASSPORT_REPLICAS": 1,
  "OXD_SERVER_REPLICAS": 1,
  "CASA_REPLICAS": 1,
  "RADIUS_REPLICAS": 1,
  "ENABLE_OXTRUST_API": "Y",
  "ENABLE_OXTRUST_TEST_MODE": "N",
  "ENABLE_CACHE_REFRESH": "Y",
  "ENABLE_OXD": "Y",
  "ENABLE_RADIUS": "Y",
  "ENABLE_OXPASSPORT": "Y",
  "ENABLE_OXSHIBBOLETH": "Y",
  "ENABLE_CASA": "Y",
  "ENABLE_KEY_ROTATE": "Y",
  "ENABLE_OXTRUST_API_BOOLEAN": "true",
  "ENABLE_OXTRUST_TEST_MODE_BOOLEAN": "false",
  "ENABLE_RADIUS_BOOLEAN": "true",
  "ENABLE_OXPASSPORT_BOOLEAN": "true",
  "ENABLE_CASA_BOOLEAN": "true",
  "ENABLE_SAML_BOOLEAN": "true",
  "EDIT_IMAGE_NAMES_TAGS": "N",
  "CONFIRM_PARAMS": "Y"
}
EOF

# Install Gluu cloud native edition
./$PYTHON_PACKAGE helm-install

# Wait for main services to run
kubectl -n gluu wait --for=condition=available --timeout=900s deploy/gluu-oxauth
kubectl -n gluu wait --for=condition=available --timeout=300s deploy/gluu-oxd-server

# Install Gluu Gateway UI
./$PYTHON_PACKAGE helm-install-gg-dbmode
