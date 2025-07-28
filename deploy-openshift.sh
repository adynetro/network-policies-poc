#!/bin/bash

# Deploy Network Policy POC for OpenShift
echo "🚀 Deploying Network Policy POC for OpenShift..."

# Check if we're running on OpenShift
if oc version &>/dev/null; then
    echo "✅ OpenShift CLI detected"
    KUBECTL_CMD="oc"
else
    echo "⚠️  Using kubectl (OpenShift CLI not found)"
    KUBECTL_CMD="kubectl"
fi

# Apply manifests in order
echo "📦 Creating namespaces..."
$KUBECTL_CMD apply -f manifests/01-namespaces.yaml

# For OpenShift, we might need to add SCC annotations or use specific SCC
echo "🔐 Applying OpenShift security configurations..."

# Add anyuid SCC if needed (for non-root containers)
if [ "$KUBECTL_CMD" = "oc" ]; then
    echo "Adding anyuid SCC to service accounts..."
    oc adm policy add-scc-to-user anyuid system:serviceaccount:app-ns:default
    oc adm policy add-scc-to-user anyuid system:serviceaccount:external-ns:default
fi

echo "🚢 Deploying applications..."
$KUBECTL_CMD apply -f manifests/02-deployments-openshift.yaml

echo "🔗 Creating services..."
$KUBECTL_CMD apply -f manifests/03-services.yaml

echo "🛡️ Applying network policies..."
$KUBECTL_CMD apply -f manifests/04-network-policies.yaml

echo "⏳ Waiting for pods to be ready..."
$KUBECTL_CMD wait --for=condition=ready pod -l app=frontend -n app-ns --timeout=120s
$KUBECTL_CMD wait --for=condition=ready pod -l app=backend -n app-ns --timeout=120s
$KUBECTL_CMD wait --for=condition=ready pod -l app=external-api -n external-ns --timeout=120s

echo "📦 Installing curl in containers..."
$KUBECTL_CMD exec -n app-ns deployment/frontend -- microdnf install -y curl || echo "⚠️ Failed to install curl in frontend"
$KUBECTL_CMD exec -n app-ns deployment/backend -- microdnf install -y curl || echo "⚠️ Failed to install curl in backend"
$KUBECTL_CMD exec -n external-ns deployment/external-api -- microdnf install -y curl || echo "⚠️ Failed to install curl in external-api"

echo "✅ Deployment complete!"
echo ""
echo "📋 Checking pod status..."
$KUBECTL_CMD get pods -n app-ns
$KUBECTL_CMD get pods -n external-ns
echo ""
echo "To test connectivity, run:"
echo "./test-scripts/test-connectivity.sh"
