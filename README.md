# Network Policies POC

This project demonstrates Kubernetes Network Policies with the following setup:

## Architecture

### Namespaces:
- `app-ns`: Contains frontend and backend deployments
- `external-ns`: Contains external-api deployment

### Deployments:
- **Frontend**: Simple nginx pod in `app-ns`
- **Backend**: Simple nginx pod in `app-ns` 
- **External API**: Simple nginx pod in `external-ns`

### Network Policy Rules:
✅ **Frontend → Backend**: ALLOWED (same namespace)  
✅ **Backend → External API**: ALLOWED (cross-namespace, explicit policy)  
✅ **External API → google.ro**: ALLOWED (internet access with HTTP/HTTPS)  
🚫 **External API → Backend**: BLOCKED (no return path)  
🚫 **External API → Frontend**: BLOCKED (no return path)  
🚫 **Frontend → External API**: BLOCKED (no direct access)

## Quick Start

1. Deploy the POC:
```bash
./deploy.sh
```

2. Run automated tests:
```bash
./test-scripts/test-connectivity.sh
```

3. Or run manual tests:
```bash
# Test from frontend to backend (should work - HTTP 200)
kubectl exec -n app-ns deployment/frontend -- curl -s -w '\n%{http_code}\n' http://backend.app-ns.svc.cluster.local

# Test from backend to external-api (should work - HTTP 200)
kubectl exec -n app-ns deployment/backend -- curl -s -w '\n%{http_code}\n' http://external-api.external-ns.svc.cluster.local

# Test from external-api to backend (should timeout/fail)
kubectl exec -n external-ns deployment/external-api -- curl -s --max-time 5 http://backend.app-ns.svc.cluster.local

# Test external-api access to google.ro (should work)
kubectl exec -n external-ns deployment/external-api -- curl -s --max-time 10 https://google.ro
```

4. Test Google access specifically:
```bash
./test-scripts/test-google-access.sh
```

5. Cleanup when done:
```bash
./cleanup.sh
```

## Files Structure

- `manifests/01-namespaces.yaml`: Namespace definitions
- `manifests/02-deployments.yaml`: Application deployments  
- `manifests/03-services.yaml`: Service definitions
- `manifests/04-network-policies.yaml`: Standard Kubernetes network policy rules
- `manifests/05-calico-domain-policy.yaml`: Example Calico policies for domain filtering
- `deploy.sh`: Deployment script
- `cleanup.sh`: Cleanup script
- `test-scripts/test-connectivity.sh`: Automated connectivity tests
- `test-scripts/test-google-access.sh`: Specific Google access testing
- `test-scripts/manual-tests.sh`: Manual test commands reference

## Network Policy Details

The setup creates 5 network policies:

1. **allow-frontend-to-backend**: Allows frontend pods to access backend pods (port 80)
2. **allow-backend-to-external**: Allows backend pods to access external-ns (egress)
3. **allow-external-api-ingress**: Allows external-api to receive traffic only from backend
4. **external-api-egress-google-only**: Allows external-api to access internet (HTTP/HTTPS) including google.ro
5. **frontend-egress-policy**: Limits frontend to only access backend (no external access)

### Important Notes on Domain Filtering

⚠️ **Kubernetes NetworkPolicies Limitation**: Standard Kubernetes NetworkPolicies work at Layer 3/4 (IP/Port) and cannot filter by domain names directly.

**For true domain-specific filtering, consider:**
- **Service Mesh**: Istio with egress gateways
- **Calico NetworkPolicies**: Enhanced policies with domain support (see `05-calico-domain-policy.yaml`)
- **DNS-based filtering**: Custom DNS servers
- **Application-level controls**: HTTP proxies, application firewalls

**Current Implementation**: The policy allows HTTP/HTTPS traffic to any external IP, which includes google.ro but cannot restrict to only google.ro using standard Kubernetes NetworkPolicies.
