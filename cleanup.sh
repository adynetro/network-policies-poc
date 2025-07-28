#!/bin/bash

# Cleanup Network Policy POC
echo "🧹 Cleaning up Network Policy POC..."

echo "🗑️ Deleting network policies..."
kubectl delete networkpolicy --all -n app-ns
kubectl delete networkpolicy --all -n external-ns

echo "🗑️ Deleting services..."
kubectl delete -f manifests/03-services.yaml

echo "🗑️ Deleting deployments..."
kubectl delete -f manifests/02-deployments.yaml

echo "🗑️ Deleting namespaces..."
kubectl delete -f manifests/01-namespaces.yaml

echo "✅ Cleanup complete!"
