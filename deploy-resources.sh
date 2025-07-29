#!/bin/bash
# Deploy all resources
kubectl apply -f namespace.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f backend-service.yaml
