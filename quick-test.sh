#!/bin/bash

echo "🔧 Quick Network Policy Test Script"
echo "==================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

echo "1. Checking pod status..."
kubectl get pods -n app-ns -o wide
kubectl get pods -n external-ns -o wide

echo ""
echo "2. Testing Frontend → Backend (should work)..."
if kubectl exec -n app-ns frontend -- curl -s --max-time 5 http://backend.app-ns.svc.cluster.local >/dev/null 2>&1; then
    echo "✅ Frontend → Backend: SUCCESS"
else
    echo "❌ Frontend → Backend: FAILED"
fi

echo ""
echo "3. Testing Backend → External API (should work)..."
if kubectl exec -n app-ns backend -- curl -s --max-time 5 http://external-api.external-ns.svc.cluster.local >/dev/null 2>&1; then
    echo "✅ Backend → External API: SUCCESS"
else
    echo "❌ Backend → External API: FAILED"
fi

echo ""
echo "4. Testing External API → Backend (should fail)..."
if kubectl exec -n external-ns external-api -- curl -s --max-time 5 http://backend.app-ns.svc.cluster.local >/dev/null 2>&1; then
    echo "⚠️  External API → Backend: UNEXPECTED SUCCESS (should be blocked)"
else
    echo "✅ External API → Backend: BLOCKED (as expected)"
fi

echo ""
echo "5. Testing External API → Internet (should work)..."
if kubectl exec -n external-ns external-api -- curl -s --max-time 10 https://google.ro >/dev/null 2>&1; then
    echo "✅ External API → Internet: SUCCESS"
else
    echo "❌ External API → Internet: FAILED (check internet connectivity)"
fi

echo ""
echo "🔍 If tests are failing, try:"
echo "   - kubectl apply -f all-in-one.yaml"
echo "   - kubectl get networkpolicy -A"
echo "   - kubectl describe networkpolicy -n app-ns"
echo "   - kubectl describe networkpolicy -n external-ns"
