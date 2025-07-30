# Network Policies Proof of Concept

## Overview
This project demonstrates Kubernetes NetworkPolicies in OpenShift environments using `nginxinc/nginx-unprivileged` containers. It showcases controlled network traffic between frontend and backend pods with comprehensive testing.

## Architecture
- **Namespace**: `app-network`
- **Frontend (fe)**: NGINX pod that can access backend but not internet
- **Backend (be)**: NGINX pod that accepts traffic from frontend only
- **Services**: ClusterIP services for internal communication

## Network Policies Implemented

### 1. Allow Frontend → Backend
- **Policy**: `allow-fe-to-be`
- **Effect**: Frontend pods can access backend pods
- **Test**: ✅ Should succeed

### 2. Block Backend → Frontend  
- **Policy**: `deny-be-to-fe`
- **Effect**: Backend pods cannot access frontend pods
- **Test**: ❌ Should fail (policy working)

### 3. Block Frontend → Internet
- **Policy**: `deny-fe-internet`
- **Effect**: Frontend pods cannot access external websites
- **Allows**: Internal cluster communication, DNS, backend access
- **Test**: ❌ Should fail when accessing google.com

## Files Structure
```
├── simple-poc.yaml    # All-in-one manifest (namespace, deployments, services, policies)
├── test-poc.sh        # Automated testing script
├── cleanup-poc.sh     # Cleanup script
└── README.md          # This file
```

## Quick Start

### Deploy and Test
```bash
# Run complete test suite
./test-poc.sh
```

### Manual Deployment
```bash
# Deploy resources
kubectl apply -f simple-poc.yaml

# Check status
kubectl get pods -n app-network
kubectl get networkpolicy -n app-network
```

### Cleanup
```bash
# Remove all resources
./cleanup-poc.sh
```

## Expected Test Results
```
=== Test 1: Frontend → Backend (should SUCCEED) ===
✅ SUCCESS: Frontend can access Backend

=== Test 2: Backend → Frontend (should FAIL) ===
✅ SUCCESS: Backend cannot access Frontend (policy working)

=== Test 3: Frontend → Internet (should FAIL) ===
✅ SUCCESS: Frontend cannot access Internet (policy working)
```

## NetworkPolicy Details

### Frontend Egress Policy
- Allows access to backend pods only
- Permits DNS resolution (port 53)
- Allows internal cluster communication (private IP ranges)
- Blocks all internet traffic

### Backend Ingress Policy
- Accepts traffic from frontend pods only
- No egress restrictions (can access internet)

### Frontend Ingress Policy
- Denies all incoming traffic (including from backend)

## Troubleshooting

### Common Issues
1. **Timeout errors**: Check if DNS/service discovery is working
2. **Policy not applied**: Verify NetworkPolicy resources exist
3. **Pods not ready**: Wait for pod readiness before testing

### Debug Commands
```bash
# Check pods
kubectl get pods -n app-network -o wide

# Check services  
kubectl get svc -n app-network

# Check network policies
kubectl get networkpolicy -n app-network

# Describe policies
kubectl describe networkpolicy -n app-network

# Test connectivity manually
kubectl exec -n app-network <fe-pod> -- curl -v be-service.app-network.svc.cluster.local
```

## Requirements
- Kubernetes cluster with NetworkPolicy support
- kubectl configured
- OpenShift (optional, but designed for OpenShift compatibility)