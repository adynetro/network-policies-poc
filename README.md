# Simple Network Policy POC

This is a minimal setup to demonstrate Kubernetes Network Policies.

## Setup
- 2 namespaces: `app-ns` and `external-ns`
- 3 deployments: frontend, backend (in app-ns), external-api (in external-ns)
- Network policies to control traffic flow

## Deploy
```bash
kubectl apply -f all-in-one.yaml
```

## Test
```bash
# Should work: Frontend → Backend
kubectl exec -n app-ns deployment/frontend -- curl -s backend.app-ns.svc.cluster.local

# Should work: Backend → External API  
kubectl exec -n app-ns deployment/backend -- curl -s external-api.external-ns.svc.cluster.local

# Should fail: External API → Backend
kubectl exec -n external-ns deployment/external-api -- curl -s backend.app-ns.svc.cluster.local --max-time 5
```

## Cleanup
```bash
kubectl delete -f all-in-one.yaml
```
