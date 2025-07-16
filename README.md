# Authentik CI/CD with Helm and ArgoCD

This repository provides a complete CI/CD pipeline for Authentik using GitHub Actions, Helm charts, and ArgoCD for GitOps deployment.

## 🏗️ Architecture

### CI/CD Pipeline
- **GitHub Actions**: Build custom images and push to Docker Hub
- **Helm Charts**: Kubernetes deployment manifests
- **ArgoCD**: GitOps continuous deployment
- **Vault**: Secure secret management
- **Self-hosted Runner**: Build and deployment execution

### Components
- **Authentik Server**: Identity provider (Custom Docker image)
- **Authentik Worker**: Background tasks (Custom Docker image)
- **Nginx**: Reverse proxy with SSL (Custom Docker image)
- **PostgreSQL**: Database (Bitnami Helm Chart)
- **Redis**: Cache and sessions (Bitnami Helm Chart)

## 🔧 Prerequisites

### Infrastructure Requirements
- **Kubernetes Cluster**: With ArgoCD installed
- **Self-hosted GitHub Runner**: With Docker, kubectl, and ArgoCD CLI
- **HashiCorp Vault**: For secret management
- **Docker Hub Account**: For custom image storage
- **SSL Certificates**: Let's Encrypt certificates for authentik.srespace.tech

### GitHub Secrets
Configure these secrets in your GitHub repository:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `VAULT_TOKEN` | Vault access token | `hvs.XXXXXXXXXXXXXXX` |
| `DOCKER_PASSWORD` | Docker Hub token | `dckr_pat_XXXXXXX` |

### Environment Variables
The workflow uses these environment variables:

| Variable | Value | Description |
|----------|-------|-------------|
| `VAULT_ADDR` | `http://192.168.0.116:8200` | Vault server address |
| `VAULT_PATH` | `secret/Dev-secret/authentik` | Vault secret path |
| `DOCKER_USER` | `noletengine` | Docker Hub username |

### Vault Configuration
Ensure these secrets exist at `secret/Dev-secret/authentik`:

| Key | Description |
|-----|-------------|
| `authentik_secret_key` | Authentik encryption key |
| `pg_pass` | PostgreSQL password |
| `smtp_host` | SMTP server hostname |
| `smtp_port` | SMTP port (587) |
| `smtp_user` | SMTP username |
| `smtp_pass` | SMTP password |
| `domain_name` | Domain (authentik.srespace.tech) |

## 🚀 Deployment Process

### 1. ArgoCD Setup

Install ArgoCD in your cluster:

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 2. Create ArgoCD Application

The ArgoCD application is automatically applied by the GitHub Actions workflow:

```bash
# ArgoCD application is applied automatically during CI/CD
kubectl apply -f authentik/argocd/application.yaml
```

### 3. Trigger Deployment

Push code to trigger the CI/CD pipeline:

```bash
git add .
git commit -m "Deploy Authentik with ArgoCD"
git push origin main
```

## 📋 CI/CD Pipeline Stages

### Stage 1: Build and Push Images
1. **Checkout**: Get source code
2. **Vault**: Import secrets from HashiCorp Vault
3. **Build**: Create containers with docker-compose
4. **Commit**: Convert running containers to custom images
5. **Push**: Upload images to Docker Hub with proper tags

### Stage 2: Update Helm Values
1. **Extract Tag**: Get image tag from build stage
2. **Update**: Modify Helm values.yaml with new image tag
3. **Commit**: Push updated values to trigger ArgoCD sync

### Stage 3: ArgoCD Deployment
1. **Login**: Authenticate with ArgoCD server
2. **Create/Update**: Ensure ArgoCD application exists
3. **Sync**: Deploy to Kubernetes cluster
4. **Wait**: Monitor deployment completion
5. **Verify**: Check pod and service status

## 🔄 GitOps Workflow

### Automated Sync
- **Push to main/develop** → GitHub Actions builds images
- **Helm values updated** → ArgoCD detects changes
- **Auto-sync enabled** → ArgoCD deploys to Kubernetes
- **Self-healing** → ArgoCD corrects configuration drift

### Manual Operations
```bash
# Check application status
kubectl get application authentik -n argocd

# View application details
kubectl describe application authentik -n argocd

# Force sync (if needed)
kubectl patch application authentik -n argocd --type merge -p '{"operation":{"sync":{"syncStrategy":{"hook":{"force":true}}}}}'

# Delete application
kubectl delete application authentik -n argocd
```

## 📁 Project Structure

```
authentik/
├── .github/workflows/
│   └── deploy-authentik.yml          # Complete CI/CD pipeline
├── argocd/
│   ├── application.yaml              # ArgoCD application manifest
├── helm/authentik-chart/
│   ├── Chart.yaml                    # Helm chart metadata
│   ├── values.yaml                   # Default configuration
│   └── templates/                    # Kubernetes manifests
├── nginx/
│   ├── nginx.conf.template           # Nginx configuration
│   └── ssl.conf                      # SSL settings
├── docker-compose.yml                # Container orchestration
└── README.md                         # This file
```

## 🔐 Security Features

### Image Security
- **Custom Images**: Built from official Authentik images
- **Secret Injection**: Configuration baked into images at build time
- **Registry Security**: Images stored in private Docker Hub repository

### Kubernetes Security
- **RBAC**: Role-based access control
- **Network Policies**: Service isolation
- **Pod Security**: Non-root containers
- **TLS**: End-to-end encryption

### GitOps Security
- **ArgoCD RBAC**: Project-based access control
- **Vault Integration**: Secrets never stored in Git
- **Automated Sync**: Reduces manual intervention

## 🏭 Production Considerations

### High Availability
- **Multiple Replicas**: Server and worker pods
- **Database Clustering**: PostgreSQL with replication
- **Load Balancing**: Kubernetes services
- **Auto-scaling**: HPA based on CPU/memory

### Monitoring
- **ArgoCD Dashboard**: Deployment status and history
- **Kubernetes Metrics**: Pod and service monitoring
- **Application Logs**: Centralized logging
- **Health Checks**: Liveness and readiness probes

### Backup and Recovery
- **Database Backups**: Automated PostgreSQL backups
- **Configuration Backup**: Helm values in Git
- **Disaster Recovery**: Multi-cluster deployment
- **Rollback**: ArgoCD revision history

## 🛠️ Operations

### Viewing Deployment Status
```bash
# Check ArgoCD application
kubectl get application authentik -n argocd

# Kubernetes resources
kubectl get all -n authentik

# Pod logs
kubectl logs -f deployment/authentik-server -n authentik
```

### Scaling
```bash
# Scale server replicas
kubectl scale deployment authentik-server --replicas=3 -n authentik

# Update Helm values for permanent scaling
# Edit helm/authentik-chart/values.yaml
# Commit changes to trigger ArgoCD sync
```

### Updates
```bash
# Update image tag in Helm values
# Push changes to trigger CI/CD pipeline
git add helm/authentik-chart/values.yaml
git commit -m "Update to version X.Y.Z"
git push origin main
```

### Troubleshooting
```bash
# Check ArgoCD application status
kubectl describe application authentik -n argocd

# Check ArgoCD controller logs
kubectl logs -n argocd deployment/argocd-application-controller

# Check pod events
kubectl describe pod <pod-name> -n authentik

# View application logs
kubectl logs -f deployment/authentik-server -n authentik
```

## 🔍 Monitoring and Alerting

### ArgoCD Monitoring
- **Sync Status**: Application health and sync state
- **Resource Status**: Kubernetes resource health
- **Deployment History**: Revision tracking and rollback capability

### Kubernetes Monitoring
- **Pod Status**: Running, pending, failed pods
- **Resource Usage**: CPU, memory, storage metrics
- **Network**: Service connectivity and ingress status

### Application Monitoring
- **Health Endpoints**: Authentik API health checks
- **Performance**: Response times and throughput
- **Security**: Authentication and authorization metrics

## 📚 Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Authentik Documentation](https://docs.goauthentik.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitOps Principles](https://www.gitops.tech/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with ArgoCD
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🚀 Quick Start Commands

```bash
# Apply ArgoCD application (done automatically by CI/CD)
kubectl apply -f authentik/argocd/

# Trigger CI/CD pipeline
git push origin main

# Check deployment status
kubectl get application authentik -n argocd

# Access Authentik
open https://authentik.srespace.tech
```# Trigger build
