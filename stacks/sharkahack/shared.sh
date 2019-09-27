#!/bin/sh

set -e

if [ -z "${DO_API_TOKEN}" ]; then
  echo "Error: DO_API_TOKEN not defined."
  exit 1
fi

if [ -z "${DOMAIN}" ]; then
  echo "Error: DOMAIN not defined."
  exit 1
fi

kubectl config set-context --current --namespace=prometheus-operator

################################################################################
# determine cluster uuid
################################################################################
CLUSTER_UUID=$(kubectl cluster-info | head -n 1 | cut -c59-94)

################################################################################
# create basic auth secret
################################################################################
USERNAME=do-user
PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)
BASIC_AUTH="${USERNAME}:$(openssl passwd -apr1 "${PASSWORD}")"
BASIC_AUTH_BASE64=$(printf "%s" "${BASIC_AUTH}" | base64 | tr -d \\n)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth
type: Opaque
data:
  auth: $BASIC_AUTH_BASE64
EOF

################################################################################
# create ingress
################################################################################
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-type: basic
spec:
  rules:
  - host: alertmanager.${CLUSTER_UUID}.dohackafun.com
    http:
      paths:
      - path: /
        backend:
          serviceName: prometheus-operator-alertmanager
          servicePort: 9093
  - host: grafana.${CLUSTER_UUID}.dohackafun.com
    http:
      paths:
      - path: /
        backend:
          serviceName: prometheus-operator-grafana
          servicePort: 80
  - host: prometheus.${CLUSTER_UUID}.dohackafun.com
    http:
      paths:
      - path: /
        backend:
          serviceName: prometheus-operator-prometheus
          servicePort: 9090
  tls:
  - hosts:
    - alertmanager.${CLUSTER_UUID}.dohackafun.com
    - grafana.${CLUSTER_UUID}.dohackafun.com
    - prometheus.${CLUSTER_UUID}.dohackafun.com
EOF

################################################################################
# determine load-balancer ip
################################################################################
EXTERNAL_IP=""
while [ -z $EXTERNAL_IP ]; do
  EXTERNAL_IP=$(kubectl get svc ingress-nginx -n ingress-nginx -o jsonpath --template '{.status.loadBalancer.ingress[0].ip}')
  [ -z "$EXTERNAL_IP" ] && sleep 10
done

################################################################################
# update do dns
################################################################################
generate_post_data()
{
cat <<EOF
  {
    "type": "A",
    "name": "*.$CLUSTER_UUID",
    "data": "$EXTERNAL_IP",
    "priority": null,
    "port": null,
    "ttl": 1800,
    "weight": null,
    "flags": null,
    "tag": null
  }
EOF
}

curl --silent -X POST -H "Content-Type: application/json" -H "Authorization: Bearer ${DO_API_TOKEN}" -d "$(generate_post_data)" "https://api.digitalocean.com/v2/domains/${DOMAIN}/records"

################################################################################
# return subdomains, UUID, basic auth creds
################################################################################
generate_returned_data()
{
cat <<EOF
  {
    "apps": [
      {
        "name": "alertmanager",
        "url": "alertmanager.$CLUSTER_UUID.dohackafun.com"
      },
      {
        "name": "grafana",
        "url": "grafana.$CLUSTER_UUID.dohackafun.com"
      },
      {
        "name": "prometheus",
        "url": "prometheus.$CLUSTER_UUID.dohackafun.com"
      }
    ],
    "IP": "$EXTERNAL_IP",
    "username": "$USERNAME",
    "password": "$PASSWORD"
  }
EOF
} > /tmp/"$CLUSTER_UUID"

generate_returned_data

echo /tmp/"$CLUSTER_UUID"
