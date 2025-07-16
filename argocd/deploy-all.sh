#!/bin/bash

# Deploy all ArgoCD applications for different environments
# Usage: ./deploy-all.sh [environment]

set -e

ENVIRONMENT=${1:-all}

echo "🚀 Deploying Authentik ArgoCD Applications"
echo "Environment: $ENVIRONMENT"
echo "=========================================="

deploy_app() {
    local app_file=$1
    local app_name=$2
    local env=$3
    
    echo "📦 Deploying $app_name ($env environment)..."
    kubectl apply -f "$app_file"
    echo "✅ $app_name deployed successfully"
    echo ""
}

case $ENVIRONMENT in
    "production"|"prod"|"main")
        deploy_app "application-production.yaml" "authentik-production" "production"
        ;;
    "staging"|"stage"|"develop")
        deploy_app "application-staging.yaml" "authentik-staging" "staging"
        ;;
    "sre"|"infrastructure")
        deploy_app "application-sre.yaml" "authentik-sre" "sre"
        ;;
    "all")
        deploy_app "application-production.yaml" "authentik-production" "production"
        deploy_app "application-staging.yaml" "authentik-staging" "staging"
        deploy_app "application-sre.yaml" "authentik-sre" "sre"
        ;;
    *)
        echo "❌ Unknown environment: $ENVIRONMENT"
        echo "Valid options: production, staging, sre, all"
        exit 1
        ;;
esac

echo "🎉 Deployment completed!"
echo ""
echo "📊 Check application status:"
echo "kubectl get applications -n argocd"
echo ""
echo "🔍 Monitor sync status:"
echo "kubectl get applications -n argocd -w"