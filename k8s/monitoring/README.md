# Monitoring Local Setup

The monitoring stack requires two Kubernetes secrets:

- `alertmanager-slack-webhook` with key `slack_webhook_url`
- `grafana-admin-credentials` with key `admin-password`

In CI/CD, these come from GitHub Environment Secrets.
For local runs, create them before applying kustomize.

## Option 1: Use helper script (recommended)

```bash
cd hrs-infra/k8s/monitoring
chmod +x create-local-secrets.sh
ALERTMANAGER_WEBHOOK_URL='https://hooks.slack.com/services/xxx/yyy/zzz' \
GRAFANA_ADMIN_PASSWORD='change-this-local-password' \
./create-local-secrets.sh
```

## Option 2: Create secrets manually

```bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

kubectl -n monitoring create secret generic alertmanager-slack-webhook \
  --from-literal=slack_webhook_url='https://hooks.slack.com/services/xxx/yyy/zzz' \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n monitoring create secret generic grafana-admin-credentials \
  --from-literal=admin-password='change-this-local-password' \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Deploy monitoring

```bash
kubectl apply -k hrs-infra/k8s/monitoring/overlays/uat
```
