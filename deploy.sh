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

echo "✅ Deployment complete!"
echo ""
echo "To test connectivity, run:"
echo "./test-scripts/test-connectivity.sh"
