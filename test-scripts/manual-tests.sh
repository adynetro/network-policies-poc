#!/bin/bash

# Manual test commands for Network Policy POC
echo "📋 Manual Test Commands for Network Policy POC"
echo "=============================================="
echo ""

echo "1️⃣ Test Frontend → Backend (should work):"
echo "kubectl exec -n app-ns deployment/frontend -- curl -s -w '\n%{http_code}\n' http://backend.app-ns.svc.cluster.local"
echo ""

echo "2️⃣ Test Backend → External API (should work):"
echo "kubectl exec -n app-ns deployment/backend -- curl -s -w '\n%{http_code}\n' http://external-api.external-ns.svc.cluster.local"
echo ""

echo "3️⃣ Test External API → Backend (should fail):"
echo "kubectl exec -n external-ns deployment/external-api -- curl -s --max-time 5 -w '\n%{http_code}\n' http://backend.app-ns.svc.cluster.local"
echo ""

echo "4️⃣ Test External API → Frontend (should fail):"
echo "kubectl exec -n external-ns deployment/external-api -- curl -s --max-time 5 -w '\n%{http_code}\n' http://frontend.app-ns.svc.cluster.local"
echo ""

echo "5️⃣ Test Frontend → External API (should fail):"
echo "kubectl exec -n app-ns deployment/frontend -- curl -s --max-time 5 -w '\n%{http_code}\n' http://external-api.external-ns.svc.cluster.local"
echo ""

echo "6️⃣ Test External API → google.ro (should work):"
echo "kubectl exec -n external-ns deployment/external-api -- curl -s --max-time 10 -w '\n%{http_code}\n' https://google.ro"
echo ""

echo "7️⃣ Test External API → other sites (may work due to policy limitations):"
echo "kubectl exec -n external-ns deployment/external-api -- curl -s --max-time 5 -w '\n%{http_code}\n' https://google.com"
echo ""

echo "📊 Check pod status:"
echo "kubectl get pods -n app-ns -o wide"
echo "kubectl get pods -n external-ns -o wide"
echo ""

echo "🛡️ Check network policies:"
echo "kubectl get networkpolicy -n app-ns"
echo "kubectl get networkpolicy -n external-ns"
echo ""

echo "🔍 Describe network policies:"
echo "kubectl describe networkpolicy -n app-ns"
echo "kubectl describe networkpolicy -n external-ns"
