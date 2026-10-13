# GitOps Lab (kind, free, runs on a laptop)

Prerequisites: Docker, `kind`, `kubectl`.

```bash
./local/up.sh
kubectl get application demo-app -n argocd -w   # wait for Synced / Healthy
kubectl get pods -n demo
```

## Experiments

Record what you observe (screenshots and timings) under **Lab notes** below.

### 1. Drift detection and self-heal
```bash
kubectl scale deploy demo-app -n demo --replicas=5
kubectl get deploy demo-app -n demo -w
```
Expected: Argo CD detects that the live state differs from Git and scales the deployment back to 2 replicas (`selfHeal: true`).

### 2. A change through Git
Edit `local/demo-values.yaml` (for example `replicaCount: 3`), then commit and push. Watch Argo CD sync without anyone running `kubectl apply`.

### 3. Bad release and rollback
Set `image.tag: "doesnotexist"`, then push.
```bash
kubectl get pods -n demo            # ImagePullBackOff on new pods; old pods keep serving (maxUnavailable: 0)
kubectl describe pod -n demo <pod>  # Events: Failed to pull image
```
Recover with `git revert HEAD && git push`. Argo CD rolls forward to the last good state.

### 4. Break it and debug it
Set `probes.path: /nope` and push. Use `kubectl describe pod` (readiness probe failures), `kubectl logs` and `kubectl get events -n demo --sort-by=.lastTimestamp` to find the cause.

## Lab notes
- _Self-heal time observed:_
- _What happened during the bad tag:_
- _How I found the probe failure:_

## Cleanup
```bash
kind delete cluster --name platform-local
```
