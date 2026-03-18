# Istio Base (AKS)

This folder stores version-controlled Istio control plane manifests.

Recommended workflow:

1. Generate/update manifests using `istioctl` locally.
2. Commit generated YAML here (do not run direct install in AKS from laptop).
3. Apply from CI/CD using `kubectl apply -f`.

Example generation (recommended):

```bash
./istio-1.29.1/bin/istioctl manifest generate --set profile=default > k8s/istio/base/istio-install.generated.yaml
```

Optional (only if your local `istioctl` supports it):

```bash
./istio-1.29.1/bin/istioctl profile dump default > k8s/istio/base/istio-default-profile.yaml
./istio-1.29.1/bin/istioctl manifest generate -f k8s/istio/base/istio-default-profile.yaml > k8s/istio/base/istio-install.generated.yaml
```

Expected files:

- `istio-install.generated.yaml`
- `istio-default-profile.yaml` (optional)
- `kustomization.yaml`
