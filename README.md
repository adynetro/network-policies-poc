# Simple Network Policy POC

This is a minimal setup to demonstrate Kubernetes Network Policies.

## Setup
- 2 namespaces: `app-ns` and `external-ns`
- 3 pods: frontend, backend (in app-ns), external-api (in external-ns)
- Network policies to control traffic flow

## Deploy
```bash
kubectl apply -f .
```

## Test
```bash
# Should work: Frontend → Backend
kubectl exec -n app-ns frontend -- curl -s backend.app-ns.svc.cluster.local

# Should work: Backend → External API  
kubectl exec -n app-ns backend -- curl -s external-api.external-ns.svc.cluster.local

# Should fail: External API → Backend
kubectl exec -n external-ns external-api -- curl -s backend.app-ns.svc.cluster.local --max-time 5
```

## Cleanup
```bash
kubectl delete namespace app-ns external-ns
```
