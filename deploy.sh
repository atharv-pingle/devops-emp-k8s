#!/bin/bash

# deploy.sh
set -e

# Set your container registry
REGISTRY="your-registry"
TAG="latest"

# Set your namespace
NAMESPACE="employee-app"

echo "🚀 Deploying Employee Management System..."

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Apply ConfigMap and Secrets
echo "📦 Applying ConfigMap and Secrets..."
kubectl apply -f config-map.yaml
kubectl apply -f db-secret.yaml

# Apply Database
echo "🗄️ Deploying Database..."
kubectl apply -f k8s-manifests.yaml -n $NAMESPACE

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n $NAMESPACE --timeout=120s

# Deploy Backend
echo "🔧 Deploying Backend..."
kubectl apply -f k8s-manifests.yaml -n $NAMESPACE

# Wait for backend to be ready
echo "⏳ Waiting for backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n $NAMESPACE --timeout=120s

# Deploy Frontend
echo "🎨 Deploying Frontend..."
kubectl apply -f k8s-manifests.yaml -n $NAMESPACE

# Apply Ingress
echo "🌐 Applying Ingress..."
kubectl apply -f ingress.yaml -n $NAMESPACE

# Print status
echo "📊 Deployment Status:"
kubectl get all -n $NAMESPACE

# Print ingress info
echo "🔍 Ingress Details:"
kubectl get ingress -n $NAMESPACE

echo "✅ Deployment complete!"
