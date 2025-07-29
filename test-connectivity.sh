#!/bin/bash
# Test connectivity
frontend_pod=$(kubectl get pods -n app-policies -l app=frontend -o jsonpath='{.items[0].metadata.name}')
backend_pod=$(kubectl get pods -n app-policies -l app=backend -o jsonpath='{.items[0].metadata.name}')

# Test Frontend → Backend
kubectl exec -n app-policies $frontend_pod -- curl -s backend.app-policies.svc.cluster.local:80 && echo "Frontend → Backend: SUCCESS" || echo "Frontend → Backend: FAILED"

# Test Backend → Frontend
kubectl exec -n app-policies $backend_pod -- curl -s frontend.app-policies.svc.cluster.local:80 && echo "Backend → Frontend: SUCCESS" || echo "Backend → Frontend: FAILED"
