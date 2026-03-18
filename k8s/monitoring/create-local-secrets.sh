#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="monitoring"
ALERTMANAGER_WEBHOOK_URL="${ALERTMANAGER_WEBHOOK_URL:-}"
GRAFANA_ADMIN_PASSWORD="${GRAFANA_ADMIN_PASSWORD:-}"

if [[ -z "$ALERTMANAGER_WEBHOOK_URL" ]]; then
  echo "ALERTMANAGER_WEBHOOK_URL is required"
  exit 1
fi

if [[ -z "$GRAFANA_ADMIN_PASSWORD" ]]; then
  echo "GRAFANA_ADMIN_PASSWORD is required"
  exit 1
fi

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NAMESPACE" create secret generic alertmanager-slack-webhook \
  --from-literal=slack_webhook_url="$ALERTMANAGER_WEBHOOK_URL" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NAMESPACE" create secret generic grafana-admin-credentials \
  --from-literal=admin-password="$GRAFANA_ADMIN_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Monitoring secrets are ready in namespace '$NAMESPACE'."
