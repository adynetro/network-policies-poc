kubectl apply -f manifest/namespace.yaml
kubectl apply -f manifest/frontend-deployment.yaml
kubectl apply -f manifest/backend-deployment.yaml
kubectl apply -f manifest/frontend-service.yaml
kubectl apply -f manifest/backend-service.yaml