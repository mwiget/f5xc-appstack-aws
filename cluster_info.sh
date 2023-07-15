#!/bin/bash
export KUBECONFIG=$(terraform output -json appstack | jq -r '.kubeconfig')
kubectl cluster-info
kubectl get nodes
