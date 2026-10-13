# Legacy → Kubernetes Migration Playbook

A repeatable process for moving a service from VMs or script-based deploys onto the platform.

## 1. Assess
- Inventory runtime, ports, config, secrets, persistent state, cron jobs and inbound and outbound dependencies.
- Classify the service as **stateless** (migrate first), **stateful** (keep data in RDS, ElastiCache or S3) or **singleton** (needs leader election or a Job).

## 2. Containerize
- Multi-stage Dockerfile running as a non-root user (UID 10001) with a read-only root filesystem.
- Externalize config into environment variables or a ConfigMap, and keep secrets in AWS Secrets Manager (External Secrets or the CSI driver).
- Add `/health` and `/metrics` endpoints.

## 3. Onboard to the golden-path chart
- Create `gitops/apps/<service>/values.yaml` and `application.yaml`.
- Size requests from current VM utilization (p95 CPU and memory) and start the HPA at the current VM count.

## 4. Parallel run
- Deploy to the cluster alongside the legacy hosts.
- Shift traffic with weighted DNS or ALB target groups: 5% → 25% → 50% → 100%.
- Compare error rate, p95 latency and saturation dashboards at each step, and roll back by moving the weight back.

## 5. Cut over and decommission
- Hold at 100% for a full business cycle, then remove the legacy targets.
- Right-size requests from two weeks of real data and delete the VMs.

## Exit criteria
- [ ] SLOs met for 7 days
- [ ] Alerts and runbooks in place
- [ ] Rollback tested
- [ ] Legacy hosts terminated
