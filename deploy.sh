#!/bin/bash

# Deploy Network Policy POC
echo "🚀 Deploying Network Policy POC..."

# Apply manifests in order
echo "📦 Creating namespaces..."
kubectl apply -f manifests/01-namespaces.yaml

echo "🚢 Deploying applications..."
kubectl apply -f manifests/02-deployments.yaml

echo "🔗 Creating services..."
kubectl apply -f manifests/03-services.yaml

echo "🛡️ Applying network policies..."
kubectl apply -f manifests/04-network-policies.yaml

echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n app-ns --timeout=120s
kubectl wait --for=condition=ready pod -l app=backend -n app-ns --timeout=120s
kubectl wait --for=condition=ready pod -l app=external-api -n external-ns --timeout=120s

echo "📦 Installing curl in containers..."
kubectl exec -n app-ns deployment/frontend -- microdnf install -y curl || echo "⚠️ Failed to install curl in frontend"
kubectl exec -n app-ns deployment/backend -- microdnf install -y curl || echo "⚠️ Failed to install curl in backend"
kubectl exec -n external-ns deployment/external-api -- microdnf install -y curl || echo "⚠️ Failed to install curl in external-api"

echo "✅ Deployment complete!"
echo ""
echo "To test connectivity, run:"
echo "./test-scripts/test-connectivity.sh"
