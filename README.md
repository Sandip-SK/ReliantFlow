ReliantFlow — Production-Grade CI/CD & SRE Platform
Designed and implemented an end-to-end CI/CD platform for Kubernetes workloads with automated testing, security gates, container image scanning, progressive delivery, deployment health validation, observability, and automated rollback.

GitHub
   ↓
CI
   ├── Unit Tests
   ├── SAST
   ├── Dependency Scan
   └── Docker Build
          ↓
   Container Registry
          ↓
       CD
   ├── Dev
   ├── Staging
   └── Production
          ↓
     Kubernetes
          ↓
 Prometheus / Grafana / Loki
          ↓
 Deployment Health
          ↓
    Rollback