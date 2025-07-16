# 🔐 Authentik Deployment with GitOps

A production-ready Authentik identity provider deployment using Docker Compose, Kubernetes, Helm, and ArgoCD with complete CI/CD automation.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions │───▶│   Docker Hub    │
│                 │    │                 │    │                 │
│ • Source Code   │    │ • Build Images  │    │ • Container     │
│ • Helm Charts   │    │ • Run Tests     │    │   Registry      │
│ • Workflows     │    │ • Update Helm   │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Kubernetes    │◀───│     ArgoCD      │◀───│   Git Repo      │
│                 │    │                 │    │                 │
│ • Authentik     │    │ • GitOps        │    │ • Updated       │
│ • PostgreSQL    │    │ • Auto Sync     │    │   Helm Values   │
│ • Redis         │    │ • Health Check  │    │                 │
│ • Nginx         │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🌿 Branch Strategy

- **main**: Production deployments  
- **develop**: Development/staging environment
- **sre**: Site Reliability Engineering and infrastructure changes

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Kubernetes cluster
- ArgoCD installed
- Vault server (for secrets)
- GitHub repository with secrets configured

### 1. Clone Repository

```bash
git clone https://github.com/nolet7/authentik-bobo.git
cd authentik-bobo
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit with your values
nano .env
```

### 3. Local Development

```bash
# Start local stack
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 4. Production Deployment

```bash
# Push to trigger CI/CD
git add .
git commit -m "Deploy to production"
git push origin main
```

## 📁 Project Structure

```
authentik-deployment/
├── .github/workflows/
│   └── deploy-authentik.yml          # CI/CD pipeline
├── argocd/
│   └── application.yaml              # ArgoCD application
├── certs/                            # SSL certificates
├── custom-templates/                 # Authentik templates
├── docker-compose.yml                # Local development
├── helm/authentik-chart/
│   ├── Chart.yaml                    # Helm metadata
│   ├── values.yaml                   # Configuration
│   └── templates/                    # Kubernetes manifests
├── media/                            # Authentik media files
├── nginx/
│   ├── nginx.conf.template           # Nginx configuration
│   └── ssl.conf                      # SSL settings
└── README.md                         # This file
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `AUTHENTIK_SECRET_KEY` | Authentik secret key | `your-secret-key` |
| `POSTGRES_PASSWORD` | Database password | `secure-password` |
| `SMTP_HOST` | Email server | `smtp.gmail.com` |
| `SMTP_USER` | Email username | `user@domain.com` |
| `DOMAIN_NAME` | Your domain | `auth.company.com` |

### Vault Secrets

The CI/CD pipeline retrieves secrets from HashiCorp Vault:

```bash
# Vault path: secret/Dev-secret/authentik
vault kv put secret/Dev-secret/authentik \
  AUTHENTIK_SECRET_KEY="your-secret" \
  PG_PASS="db-password" \
  SMTP_HOST="smtp.gmail.com" \
  SMTP_USER="email@domain.com" \
  SMTP_PASS="app-password" \
  DOMAIN_NAME="auth.company.com"
```

## 🔄 CI/CD Pipeline

### Workflow Triggers

- **Push to main/develop/sre**: Automatic deployment
- **Manual trigger**: `workflow_dispatch`
- **Path filters**: Only on relevant file changes

### Pipeline Stages

1. **🔨 Build & Push**
   - Install Vault CLI
   - Retrieve secrets from Vault
   - Build Docker images
   - Push to Docker Hub
   - Tag with branch and commit

2. **📝 Update Helm**
   - Update `values.yaml` with new image tags
   - Commit changes back to repository
   - Trigger ArgoCD sync

3. **🚀 Deploy**
   - Apply ArgoCD application
   - Wait for synchronization
   - Verify deployment health
   - Run health checks

### Image Tagging Strategy

```bash
# Branch-based tagging
main → main-abc123, latest
develop → develop-def456
sre → sre-ghi789

# Registry structure
noletengine/authentik-server:main-abc123
noletengine/authentik-worker:main-abc123
noletengine/authentik-postgresql:main-abc123
noletengine/authentik-redis:main-abc123
noletengine/authentik-nginx:main-abc123
```

## ☸️ Kubernetes Deployment

### Branch-Specific Deployments

Each branch deploys to its own environment with separate ArgoCD applications:

| Branch | Environment | Namespace | Domain | Resources |
|--------|-------------|-----------|---------|-----------|
| `main` | Production | `authentik-production` | `auth.yourdomain.com` | Full resources |
| `develop` | Staging | `authentik-staging` | `auth-staging.yourdomain.com` | Reduced resources |
| `sre` | SRE Testing | `authentik-sre` | `auth-sre.yourdomain.com` | Minimal resources |

### Deploy Applications

```bash
# Deploy all environments
cd argocd && ./deploy-all.sh all

# Deploy specific environment
./deploy-all.sh production
./deploy-all.sh staging  
./deploy-all.sh sre

# Check application status
kubectl get applications -n argocd
```

### Helm Chart Features

- **🔄 Auto-scaling**: HPA for server and worker
- **💾 Persistence**: PVCs for data storage
- **🔒 Security**: RBAC, security contexts
- **🌐 Ingress**: SSL termination and routing
- **📊 Monitoring**: Health checks and probes
- **🔧 Configuration**: ConfigMaps and Secrets

### ArgoCD Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: authentik
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/authentik-deployment
    targetRevision: HEAD
    path: helm/authentik-chart
  destination:
    server: https://kubernetes.default.svc
    namespace: authentik
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## 🔧 Operations

### Monitoring

```bash
# Check ArgoCD application
kubectl get application authentik -n argocd

# Check pods
kubectl get pods -n authentik

# View logs
kubectl logs -f deployment/authentik-server -n authentik
```

### Scaling

```bash
# Manual scaling
kubectl scale deployment authentik-server --replicas=3 -n authentik

# HPA status
kubectl get hpa -n authentik
```

### Troubleshooting

```bash
# Check events
kubectl get events -n authentik --sort-by='.lastTimestamp'

# Describe resources
kubectl describe pod <pod-name> -n authentik

# Check ingress
kubectl get ingress -n authentik
```

## 🔒 Security

### SSL/TLS Configuration

- **Modern TLS**: TLS 1.2 and 1.3 only
- **Strong Ciphers**: ECDHE and ChaCha20-Poly1305
- **HSTS**: HTTP Strict Transport Security
- **Security Headers**: XSS, CSRF, CSP protection

### Network Security

- **Rate Limiting**: DDoS protection
- **Network Policies**: Pod-to-pod communication
- **Service Mesh**: Optional Istio integration
- **Firewall Rules**: Ingress controller configuration

## 📈 Performance

### Optimization Features

- **Gzip Compression**: Reduced bandwidth usage
- **Static Caching**: 1-year cache headers
- **Connection Pooling**: Database optimization
- **Redis Caching**: Session and data caching

### Resource Limits

```yaml
resources:
  server:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 1Gi
```

## 🆘 Support

### Common Issues

1. **Database Connection**: Check PostgreSQL credentials
2. **Email Issues**: Verify SMTP configuration
3. **SSL Problems**: Check certificate validity
4. **Performance**: Review resource limits

### Useful Commands

```bash
# Reset admin password
kubectl exec -it deployment/authentik-server -n authentik -- ak create_admin_group

# Database backup
kubectl exec -it deployment/authentik-postgresql -n authentik -- pg_dump -U authentik authentik > backup.sql

# View configuration
kubectl get configmap authentik-config -n authentik -o yaml
```

## 📚 Documentation

- [Authentik Documentation](https://goauthentik.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**🚀 Ready for production deployment with enterprise-grade security and scalability!**