````markdown
# ReliantFlow — Production-Grade SRE & CI/CD Platform

ReliantFlow is a production-oriented Site Reliability Engineering platform built to demonstrate modern **CI/CD, Kubernetes, observability, SLO-driven deployment safety, security automation, and incident response** practices.

The project uses a small Flask application as the workload and focuses on the engineering systems around the application rather than application complexity.

---

## 🚀 Project Highlights

- Automated CI pipeline using GitHub Actions
- Automated unit testing and code coverage
- Python linting with Ruff
- Static Application Security Testing (SAST) with Bandit
- Dependency vulnerability scanning with pip-audit
- Container vulnerability scanning with Trivy
- Immutable Docker images tagged with Git SHA
- GitHub Container Registry (GHCR)
- Kubernetes deployment with rolling updates
- Kubernetes readiness and liveness probes
- Horizontal Pod Autoscaling (HPA)
- Resource requests and limits
- Kubernetes ConfigMaps and Secrets
- Prometheus metrics collection
- Grafana dashboards and investigation
- Loki centralized logging
- Grafana Alloy log collection
- ServiceMonitor-based Prometheus discovery
- Prometheus SLO alerting
- Availability and latency SLI monitoring
- Automated deployment health gates
- Automated Kubernetes rollback
- Failure injection for incident-response testing
- Metrics + logs correlation during incidents

---

# 🏗️ Architecture

```text
                         ┌────────────────────┐
                         │      Developer     │
                         └─────────┬──────────┘
                                   │
                                   ▼
                              Git Push
                                   │
                                   ▼
                         ┌────────────────────┐
                         │   GitHub Actions   │
                         │                    │
                         │ • Unit Tests       │
                         │ • Coverage         │
                         │ • Ruff             │
                         │ • Bandit           │
                         │ • pip-audit        │
                         │ • Docker Build     │
                         │ • Trivy            │
                         └─────────┬──────────┘
                                   │
                                   ▼
                          GitHub Container
                             Registry
                                   │
                                   ▼
                         ┌────────────────────┐
                         │     Kubernetes     │
                         │                    │
                         │   ReliantFlow      │
                         │   Deployment       │
                         │                    │
                         │   ┌────────────┐   │
                         │   │   Pod      │   │
                         │   └────────────┘   │
                         │   ┌────────────┐   │
                         │   │   Pod      │   │
                         │   └────────────┘   │
                         │   ┌────────────┐   │
                         │   │   Pod      │   │
                         │   └────────────┘   │
                         └─────────┬──────────┘
                                   │
                ┌──────────────────┼──────────────────┐
                │                  │                  │
                ▼                  ▼                  ▼
           Prometheus           Loki               Grafana
                │                  │                  │
                │                  │                  │
                └──────────┬───────┴──────────────────┘
                           │
                           ▼
                  SRE Investigation
                           │
                           ▼
                    SLO Health Gates
                           │
                    ┌──────┴──────┐
                    │             │
                   PASS          FAIL
                    │             │
                    ▼             ▼
                Promote       Rollback
````

---

# 🛠️ Technology Stack

| Area                | Technology                               |
| ------------------- | ---------------------------------------- |
| Application         | Python / Flask                           |
| Testing             | Pytest                                   |
| Linting             | Ruff                                     |
| SAST                | Bandit                                   |
| Dependency Security | pip-audit                                |
| Container           | Docker                                   |
| Container Security  | Trivy                                    |
| Registry            | GitHub Container Registry                |
| CI/CD               | GitHub Actions                           |
| Orchestration       | Kubernetes                               |
| Autoscaling         | Kubernetes HPA                           |
| Metrics             | Prometheus                               |
| Visualization       | Grafana                                  |
| Logging             | Loki                                     |
| Log Collection      | Grafana Alloy                            |
| Infrastructure      | Kubernetes manifests / Terraform roadmap |
| Versioning          | Git SHA immutable images                 |

---

# 📁 Repository Structure

```text
ReliantFlow/
│
├── app/
│   ├── __init__.py
│   └── main.py
│
├── tests/
│   └── test_main.py
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── hpa.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── servicemonitor.yaml
│   └── prometheus-rules.yml
│
├── scripts/
│   ├── check-slo.sh
│   └── deploy-and-verify.sh
│
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── cd.yml
│
├── Dockerfile
├── .dockerignore
├── requirements.txt
├── requirements-dev.txt
└── README.md
```

---

# 🔄 CI Pipeline

Every pull request and push to `main` goes through automated validation.

```text
Git Push
   │
   ├── Ruff
   │
   ├── Pytest
   │
   ├── Coverage
   │
   ├── Bandit
   │
   ├── pip-audit
   │
   ├── Docker Build
   │
   ├── Trivy Scan
   │
   └── Push Image
```

The container follows a **build once, scan once, deploy the same artifact** approach.

Docker images are tagged using the Git commit SHA:

```text
ghcr.io/<owner>/reliantflow:<git-sha>
```

This provides immutable deployment artifacts and makes releases traceable to source code.

---

# 🔐 Security

ReliantFlow incorporates security checks directly into the CI pipeline.

### SAST

Bandit scans the Python source code for common security issues.

```bash
bandit -r app/
```

### Dependency Security

pip-audit checks Python dependencies for known vulnerabilities.

```bash
pip-audit
```

### Container Security

Trivy scans the built container image before it is published.

```bash
trivy image <image>
```

### Container Hardening

The application runs as a non-root user.

```dockerfile
USER 10001
```

Kubernetes additionally prevents privilege escalation:

```yaml
securityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false
```

---

# ☸️ Kubernetes

The application is deployed using Kubernetes.

### Deployment

The deployment uses:

* 3 replicas
* RollingUpdate strategy
* `maxUnavailable: 0`
* `maxSurge: 1`
* CPU/memory requests and limits
* Readiness probe
* Liveness probe
* Non-root security context

Example:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1
```

This ensures that existing healthy replicas remain available while new replicas are introduced.

---

# 📈 Autoscaling

ReliantFlow uses Kubernetes HPA.

```text
Minimum replicas: 3
Maximum replicas: 10
CPU target: 70%
```

The CPU utilization target is calculated against the pod's requested CPU.

Example:

```text
CPU request = 100m
Target      = 70%

Target utilization = 70m
```

Scale-down stabilization is used to avoid aggressive scale-down during short-lived traffic fluctuations.

---

# 🔭 Observability

ReliantFlow implements three major observability signals:

```text
Metrics
Logs
Alerts
```

## Metrics

Prometheus collects application metrics exposed by the Flask Prometheus exporter.

Examples:

```promql
rate(flask_http_request_total[5m])
```

HTTP 5xx rate:

```promql
sum(
  rate(flask_http_request_total{status=~"5.."}[5m])
)
```

P95 latency:

```promql
histogram_quantile(
  0.95,
  sum by (le) (
    rate(flask_http_request_duration_seconds_bucket[5m])
  )
)
```

---

# 📊 SLO

ReliantFlow defines an availability SLO of:

```text
99.9%
```

The corresponding error budget over 30 days is approximately:

```text
43.2 minutes
```

The availability SLI is calculated using successful versus failed HTTP requests.

```text
SLI = successful requests / total requests
```

The project uses Prometheus recording rules to calculate:

```text
reliantflow:http_requests:rate5m
reliantflow:http_errors:rate5m
reliantflow:availability:ratio5m
```

---

# 🚨 Alerting

A Prometheus alert fires when the 5xx error rate exceeds the SLO threshold.

```promql
(1 - reliantflow:availability:ratio5m) > 0.001
```

The alert must remain above the threshold for two minutes before firing.

```yaml
for: 2m
```

This prevents short-lived spikes from immediately triggering an incident.

---

# 📝 Centralized Logging

Application logs are written to stdout/stderr.

Grafana Alloy discovers Kubernetes pods and forwards their logs to Loki.

```text
Application
     │
     ▼
stdout/stderr
     │
     ▼
Grafana Alloy
     │
     ▼
Loki
     │
     ▼
Grafana Explore
```

Example LogQL query:

```logql
{namespace="reliantflow", app="reliantflow"} |= "ERROR"
```

Specific failure investigation:

```logql
{namespace="reliantflow", app="reliantflow"} |= "Simulated application failure"
```

---

# 🧑‍🚒 Incident Response

ReliantFlow includes a controlled `/failure` endpoint to simulate application failures.

```text
/failure → HTTP 500
```

This allows the SRE workflow to be tested without introducing an uncontrolled production failure.

Example incident:

```text
Failure Injection
       ↓
HTTP 500 increase
       ↓
Prometheus detects error-rate increase
       ↓
SLO alert fires
       ↓
Grafana investigation
       ↓
Loki log correlation
       ↓
Identify failing endpoint
       ↓
Mitigation / rollback
       ↓
Verify SLO recovery
```

This demonstrates an end-to-end incident response workflow.

---

# 🔄 Deployment Safety

ReliantFlow doesn't rely solely on Kubernetes reporting a successful rollout.

The deployment verification process checks:

### 1. Kubernetes rollout

```bash
kubectl rollout status deployment/reliantflow
```

### 2. Availability

```promql
reliantflow:availability:ratio5m
```

Required:

```text
>= 99.9%
```

### 3. P95 latency

Required:

```text
< 500ms
```

The deployment gate therefore evaluates both infrastructure-level and application-level health.

---

# 🔙 Automated Rollback

If a deployment fails Kubernetes rollout validation:

```text
Deployment
    ↓
Rollout fails
    ↓
kubectl rollout undo
```

If application-level health gates fail:

```text
Deployment
    ↓
Pods Ready
    ↓
SLO Check
    ↓
FAIL
    ↓
Rollback
```

Example:

```bash
kubectl rollout undo deployment/reliantflow \
  -n reliantflow
```

This provides a safety mechanism against deployments that technically start successfully but negatively affect service reliability.

---

# 🧪 Failure Injection & Recovery Testing

The project intentionally tests failure scenarios rather than assuming the platform works.

Example:

```bash
curl http://localhost:8080/failure
```

Expected:

```text
HTTP 500
```

Prometheus then observes the error-rate increase.

The SLO health gate transitions from:

```text
PASS
```

to:

```text
FAIL
```

and the deployment mechanism can trigger rollback.

---

# 🩺 Deployment Health Model

ReliantFlow uses multiple layers of health validation.

```text
                Deployment
                    │
                    ▼
            Kubernetes Rollout
                    │
             Pods Ready?
              /       \
            No         Yes
            │           │
         Rollback       ▼
                  Availability ≥99.9%
                         │
                         ▼
                   P95 < 500ms
                    /       \
                  PASS       FAIL
                   │           │
                Promote     Rollback
```

This prevents relying solely on pod readiness to determine whether a deployment is safe.

---

# 🧠 SRE Principles Demonstrated

This project demonstrates several core SRE principles:

* **SLIs, SLOs and error budgets**
* **Observability-driven troubleshooting**
* **Automated deployment safety**
* **Immutable artifacts**
* **Fail-fast CI pipelines**
* **Defense-in-depth security**
* **Controlled failure injection**
* **Automated rollback**
* **Readiness vs liveness**
* **Horizontal autoscaling**
* **Metrics and logs correlation**
* **Incident detection and recovery**
* **Avoiding blind scaling**
* **Dependency-aware reliability engineering**

---

# 🚀 Running Locally

## Clone

```bash
git clone https://github.com/<your-username>/ReliantFlow.git
cd ReliantFlow
```

## Create virtual environment

```bash
python -m venv .venv
source .venv/bin/activate
```

Windows Git Bash:

```bash
source .venv/Scripts/activate
```

## Install dependencies

```bash
pip install -r requirements-dev.txt
```

## Run tests

```bash
pytest
```

## Run with coverage

```bash
pytest --cov=app --cov-report=term-missing
```

## Run linting

```bash
ruff check .
```

## Run security scan

```bash
bandit -r app/
```

## Scan dependencies

```bash
pip-audit
```

---

# 🐳 Build Docker Image

```bash
docker build -t reliantflow:local .
```

Run:

```bash
docker run --rm -p 8080:8080 \
  reliantflow:local
```

Test:

```bash
curl http://localhost:8080/health
```

---

# ☸️ Deploy to Kubernetes

Create namespace:

```bash
kubectl create namespace reliantflow
```

Apply resources:

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml
```

Verify:

```bash
kubectl get pods -n reliantflow
```

```bash
kubectl get svc -n reliantflow
```

---

# 📊 Monitoring

Verify Prometheus targets:

```bash
kubectl get servicemonitor -n monitoring
```

Port-forward Prometheus:

```bash
kubectl port-forward \
  -n monitoring \
  svc/monitoring-kube-prometheus-prometheus \
  9090:9090
```

Open:

```text
http://localhost:9090
```

Grafana:

```bash
kubectl port-forward \
  -n monitoring \
  svc/monitoring-grafana \
  3000:80
```

Open:

```text
http://localhost:3000
```

---

# 🧪 Example SRE Investigation

### Symptom

```text
ReliantFlowHighErrorRate → FIRING
```

### Investigate metrics

```promql
sum(rate(flask_http_request_total{status=~"5.."}[5m]))
```

### Check availability

```promql
reliantflow:availability:ratio5m
```

### Check latency

```promql
histogram_quantile(
  0.95,
  sum by (le) (
    rate(flask_http_request_duration_seconds_bucket[5m])
  )
)
```

### Investigate logs

```logql
{namespace="reliantflow", app="reliantflow"} |= "ERROR"
```

### Identify failure

```text
Application logs
       ↓
Failing endpoint
       ↓
Determine root cause
       ↓
Mitigate
       ↓
Verify recovery
```

---

# 📌 Future Improvements

Planned improvements include:

* Canary deployments
* Progressive delivery
* Argo Rollouts
* Automated metric analysis
* Alertmanager routing
* Kubernetes NetworkPolicies
* External Secrets / AWS Secrets Manager
* Terraform-managed infrastructure
* AWS EKS deployment
* Amazon RDS integration
* Multi-AZ architecture
* Disaster recovery testing
* Advanced multi-window SLO burn-rate alerts
* GitOps-based deployments

---

# 🎯 Project Objective

ReliantFlow was built as a hands-on SRE platform to demonstrate how a production engineering team can combine:

```text
Software Engineering
        +
CI/CD
        +
Container Security
        +
Kubernetes
        +
Observability
        +
SLOs
        +
Incident Response
        +
Automated Rollback
```

The focus is not simply deploying an application, but building the **engineering controls required to operate that application reliably in production**.

---

## Author

**Sandip Kundu**

Senior Site Reliability Engineer

Areas of focus:

* Site Reliability Engineering
* Kubernetes
* Cloud Infrastructure
* CI/CD
* Observability
* Infrastructure as Code
* Production Reliability

```