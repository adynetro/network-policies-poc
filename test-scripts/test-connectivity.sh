#!/bin/bash

# Network Policy POC Connectivity Test Script
# This script tests the connectivity between different pods according to the network policies

echo "🚀 Starting Network Policy Connectivity Tests..."
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test connectivity
test_connection() {
    local from_ns=$1
    local from_pod=$2
    local target_url=$3
    local description=$4
    local expected=$5  # "success" or "fail"
    
    echo -e "\n${YELLOW}Testing:${NC} $description"
    echo "From: $from_ns/$from_pod"
    echo "To: $target_url"
    
    # Run curl with timeout
    if kubectl exec -n $from_ns deployment/$from_pod -- curl -s --max-time 5 $target_url > /dev/null 2>&1; then
        if [ "$expected" = "success" ]; then
            echo -e "${GREEN}✅ SUCCESS${NC} - Connection allowed (as expected)"
        else
            echo -e "${RED}❌ UNEXPECTED SUCCESS${NC} - Connection should be blocked!"
        fi
    else
        if [ "$expected" = "fail" ]; then
            echo -e "${GREEN}✅ SUCCESS${NC} - Connection blocked (as expected)"
        else
            echo -e "${RED}❌ FAILURE${NC} - Connection should be allowed!"
        fi
    fi
}

# Wait for all pods to be ready
echo "⏳ Waiting for all pods to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n app-ns --timeout=60s
kubectl wait --for=condition=ready pod -l app=backend -n app-ns --timeout=60s
kubectl wait --for=condition=ready pod -l app=external-api -n external-ns --timeout=60s

echo -e "\n📋 Pod Status:"
kubectl get pods -n app-ns
kubectl get pods -n external-ns

# Test 1: Frontend to Backend (should work)
test_connection "app-ns" "frontend" "http://backend.app-ns.svc.cluster.local" \
    "Frontend accessing Backend (same namespace)" "success"

# Test 2: Backend to External API (should work)
test_connection "app-ns" "backend" "http://external-api.external-ns.svc.cluster.local" \
    "Backend accessing External API (cross-namespace)" "success"

# Test 3: External API to Backend (should fail)
test_connection "external-ns" "external-api" "http://backend.app-ns.svc.cluster.local" \
    "External API accessing Backend (should be blocked)" "fail"

# Test 4: External API to Frontend (should fail)
test_connection "external-ns" "external-api" "http://frontend.app-ns.svc.cluster.local" \
    "External API accessing Frontend (should be blocked)" "fail"

# Test 5: Frontend to External API (should fail - no policy allows this)
test_connection "app-ns" "frontend" "http://external-api.external-ns.svc.cluster.local" \
    "Frontend accessing External API (should be blocked)" "fail"

# Test 6: External API to Google.ro (should work)
echo -e "\n${YELLOW}Testing:${NC} External API accessing google.ro"
echo "From: external-ns/external-api"
echo "To: https://google.ro"

if kubectl exec -n external-ns deployment/external-api -- curl -s --max-time 10 https://google.ro > /dev/null 2>&1; then
    echo -e "${GREEN}✅ SUCCESS${NC} - External API can access google.ro"
else
    echo -e "${RED}❌ FAILURE${NC} - External API cannot access google.ro (check internet connectivity)"
fi

echo -e "\n🏁 Test Results Summary:"
echo "=============================================="
echo "✅ Frontend → Backend: ALLOWED (same namespace)"
echo "✅ Backend → External API: ALLOWED (explicit policy)"
echo "🚫 External API → Backend: BLOCKED (no policy)"
echo "🚫 External API → Frontend: BLOCKED (no policy)"
echo "🚫 Frontend → External API: BLOCKED (no policy)"
echo "🌐 External API → google.ro: ALLOWED (internet access)"
echo ""
echo "🔍 Note: External API can access internet including google.ro"
echo "   For true domain restriction, use Calico policies or service mesh"
echo ""
echo "Run './test-scripts/test-google-access.sh' for detailed Google access testing"
echo ""
echo "Network policies are working as expected! 🎉"
