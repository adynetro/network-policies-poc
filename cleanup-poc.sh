#!/bin/bash

echo "=== Cleaning up POC ==="
kubectl delete -f simple-poc.yaml

echo "=== Cleanup complete ==="
