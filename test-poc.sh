#!/bin/bash

echo "=== Deploying POC ==="
kubectl apply -f simple-poc.yaml

echo "=== Waiting for pods to be ready ==="
kubectl wait --for=condition=ready pod -l app=fe -n app-network --timeout=60s
kubectl wait --for=condition=ready pod -l app=be -n app-network --timeout=60s

echo "=== Testing Network Policies ==="

# Get pod names
FE_POD=$(kubectl get pods -n app-network -l app=fe -o jsonpath='{.items[0].metadata.name}')
BE_POD=$(kubectl get pods -n app-network -l app=be -o jsonpath='{.items[0].metadata.name}')

echo "Frontend pod: $FE_POD"
echo "Backend pod: $BE_POD"

echo ""
echo "=== Test 1: Frontend → Backend (should SUCCEED) ==="
if kubectl exec -n app-network $FE_POD -- curl -s --connect-timeout 5 -o /dev/null -w "%{http_code}" be-service.app-network.svc.cluster.local:80 | grep -q "200"; then
    echo "✅ SUCCESS: Frontend can access Backend"
else
    echo "❌ FAILED: Frontend cannot access Backend"
fi

echo ""
echo "=== Test 2: Backend → Frontend (should FAIL) ==="
if timeout 10s kubectl exec -n app-network $BE_POD -- curl -s --connect-timeout 5 -o /dev/null -w "%{http_code}" fe-service.app-network.svc.cluster.local:80 | grep -q "200"; then
    echo "❌ FAILED: Backend can access Frontend (policy not working)"
else
    echo "✅ SUCCESS: Backend cannot access Frontend (policy working)"
fi

echo ""
echo "=== Test 3: Frontend → Internet (should FAIL) ==="
if timeout 10s kubectl exec -n app-network $FE_POD -- curl -s --connect-timeout 5 -o /dev/null -w "%{http_code}" google.com | grep -q "200"; then
    echo "❌ FAILED: Frontend can access Internet (policy not working)"
else
    echo "✅ SUCCESS: Frontend cannot access Internet (policy working)"
fi

echo ""
echo "=== Network Policy Status ==="
kubectl get networkpolicy -n app-network
