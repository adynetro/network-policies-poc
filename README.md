# OpenShift NetworkPolicy Proof of Concept

## Overview
This project demonstrates the use of OpenShift NetworkPolicies to control traffic between pods in a namespace. It includes two deployments (`frontend` and `backend`) using the `nginxinc/nginx-unprivileged` image, along with services and NetworkPolicies to manage ingress and egress traffic.

## Project Structure
- **manifest/**: Contains all YAML manifests for resources and policies.
  - `namespace.yaml`: Creates the `app-policies` namespace.
  - `frontend-deployment.yaml`: Defines the `frontend` deployment.
  - `backend-deployment.yaml`: Defines the `backend` deployment.
  - `frontend-service.yaml`: Exposes the `frontend` deployment.
  - `backend-service.yaml`: Exposes the `backend` deployment.
  - `enable-networkpolicy.yaml`: Enables the NetworkPolicy to allow `frontend` → `backend` traffic.
  - `disable-networkpolicy.yaml`: Disables all ingress traffic.
- **Scripts**:
  - `deploy-resources.sh`: Deploys all resources.
  - `enable-networkpolicy.sh`: Enables the NetworkPolicy.
  - `disable-networkpolicy.sh`: Disables the NetworkPolicy.
  - `test-connectivity.sh`: Tests connectivity between `frontend` and `backend`.

## Usage

### Deploy Resources
Run the following command to deploy all resources:
```bash
bash deploy-resources.sh
```

### Enable NetworkPolicy
Run the following command to enable the NetworkPolicy:
```bash
bash enable-networkpolicy.sh
```

### Disable NetworkPolicy
Run the following command to disable the NetworkPolicy:
```bash
bash disable-networkpolicy.sh
```

### Test Connectivity
Run the following command to test connectivity:
```bash
bash test-connectivity.sh
```

## Notes
- Ensure you have `kubectl` configured to interact with your OpenShift cluster.
- The `nginxinc/nginx-unprivileged` image is used to comply with OpenShift's security policies.
- NetworkPolicies are applied to control traffic between pods and to/from external sources.

Feel free to modify the manifests and scripts to suit your requirements.
