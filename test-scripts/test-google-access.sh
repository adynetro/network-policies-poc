#!/bin/bash

# Test script specifically for google.ro access from external-api pod
echo "🌐 Testing External API access to google.ro"
echo "============================================="

# Function to test google.ro connectivity
test_google_access() {
    echo "🔍 Testing access to google.ro from external-api pod..."
    
    # Test HTTP access to google.ro
    echo "📡 Testing HTTP access to google.ro..."
    if kubectl exec -n external-ns deployment/external-api -- curl -s --max-time 10 -w '\nHTTP Code: %{http_code}\n' http://google.ro | head -20; then
        echo "✅ HTTP access to google.ro: SUCCESS"
    else
        echo "❌ HTTP access to google.ro: FAILED"
    fi
    
    echo ""
    
    # Test HTTPS access to google.ro
    echo "🔒 Testing HTTPS access to google.ro..."
    if kubectl exec -n external-ns deployment/external-api -- curl -s --max-time 10 -w '\nHTTP Code: %{http_code}\n' https://google.ro | head -20; then
        echo "✅ HTTPS access to google.ro: SUCCESS"
    else
        echo "❌ HTTPS access to google.ro: FAILED"
    fi
    
    echo ""
    
    # Test access to other sites (should work due to policy limitations)
    echo "⚠️  Testing access to other sites (google.com)..."
    if kubectl exec -n external-ns deployment/external-api -- curl -s --max-time 5 -w '\nHTTP Code: %{http_code}\n' https://google.com >/dev/null 2>&1; then
        echo "⚠️  Access to google.com: SUCCESS (Note: NetworkPolicy cannot block by domain)"
    else
        echo "🚫 Access to google.com: BLOCKED"
    fi
}

# Wait for pods to be ready
echo "⏳ Waiting for external-api pod to be ready..."
kubectl wait --for=condition=ready pod -l app=external-api -n external-ns --timeout=60s

# Check if external-api pod has internet connectivity
echo "📋 External API Pod Status:"
kubectl get pods -n external-ns -l app=external-api -o wide

echo ""
test_google_access

echo ""
echo "📝 Note: Kubernetes NetworkPolicies work at Layer 3/4 and cannot filter by domain names."
echo "   For domain-specific filtering, consider using:"
echo "   1. Service mesh (Istio) with egress gateways"
echo "   2. DNS-based filtering"
echo "   3. Application-level controls"
echo "   4. Calico network policies (if using Calico CNI)"
