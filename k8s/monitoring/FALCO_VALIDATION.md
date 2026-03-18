# Falco Validation Steps (Day 4)

Use this checklist after deploying the monitoring overlay.

## 1. Deploy monitoring stack with Falco

```bash
kubectl apply -k hrs-infra/k8s/monitoring/overlays/uat
```

## 2. Verify Falco resources

```bash
kubectl get ds -n monitoring falco
kubectl get pods -n monitoring -l app=falco
kubectl get sa -n monitoring falco
kubectl get clusterrole falco
kubectl get clusterrolebinding falco
```

Expected:

- DaemonSet desired pods equals node count.
- Falco pods are `Running`.

## 3. Validate Falco startup and rule loading

```bash
kubectl logs -n monitoring -l app=falco --tail=200
```

Look for:

- Falco initialized successfully.
- No fatal errors loading `/etc/falco/falco_rules.local.yaml`.

## 4. Trigger controlled runtime detections

Run an interactive shell in a non-critical pod:

```bash
kubectl exec -it -n uat deploy/hrs-gateway-uat -c hrs-gateway -- sh
```

Inside the container, run:

```bash
touch /etc/falco-day4-test
```

Then verify Falco reported events:

```bash
kubectl logs -n monitoring -l app=falco --tail=300 | grep -E "Terminal shell in container|Container write below /etc"
```

## 5. Validate alert forwarding path

If Loki and Alertmanager are configured:

```bash
kubectl logs -n monitoring deploy/loki --tail=200
kubectl logs -n monitoring deploy/alertmanager --tail=200
```

Confirm:

- Loki ruler evaluates rules.
- Alerts reach Alertmanager and are forwarded to Slack.

## 6. Rollback procedure (Falco only)

```bash
kubectl delete ds -n monitoring falco
kubectl delete configmap -n monitoring falco-config
kubectl delete sa -n monitoring falco
kubectl delete clusterrole falco
kubectl delete clusterrolebinding falco
```
