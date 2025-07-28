#!/bin/bash

echo "🔍 Testing container capabilities..."

# Check if pods are running
echo "📋 Pod Status:"
kubectl get pods -n app-ns -o wide
kubectl get pods -n external-ns -o wide

echo ""
echo "🧪 Testing curl availability in containers..."

# Test curl in frontend
echo "Testing curl in frontend pod..."
if kubectl exec -n app-ns deployment/frontend -- curl --version; then
    echo "✅ curl is available in frontend"
else
    echo "❌ curl not available in frontend, installing..."
    kubectl exec -n app-ns deployment/frontend -- microdnf install -y curl
fi

echo ""
# Test curl in backend
echo "Testing curl in backend pod..."
if kubectl exec -n app-ns deployment/backend -- curl --version; then
    echo "✅ curl is available in backend"
else
    echo "❌ curl not available in backend, installing..."
    kubectl exec -n app-ns deployment/backend -- microdnf install -y curl
fi

echo ""
# Test curl in external-api
echo "Testing curl in external-api pod..."
if kubectl exec -n external-ns deployment/external-api -- curl --version; then
    echo "✅ curl is available in external-api"
else
    echo "❌ curl not available in external-api, installing..."
    kubectl exec -n external-ns deployment/external-api -- microdnf install -y curl
fi

echo ""
echo "🌐 Testing HTTP servers..."

# Test if the HTTP servers are responding
echo "Testing frontend HTTP server..."
kubectl exec -n app-ns deployment/frontend -- curl -s http://localhost:8080

echo ""
echo "Testing backend HTTP server..."
kubectl exec -n app-ns deployment/backend -- curl -s http://localhost:8080

echo ""
echo "Testing external-api HTTP server..."
kubectl exec -n external-ns deployment/external-api -- curl -s http://localhost:8080
