#!/bin/bash
export KUBECONFIG=$(terraform output -json appstack | jq -r '.kubeconfig')
echo ""
kubectl cluster-info
echo ""
kubectl get nodes
