#!/bin/bash
# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands

kubectl api-resources
kubectl get namespaces
kubectl get roles --all-namespaces
kubectl get rolebindings --all-namespaces
kubectl get clusterroles --all-namespaces
kubectl get clusterrolebindings --all-namespaces
kubectl get pods --all-namespaces
#kubectl create namespace interview-test --dry-run=client|server|none
kubectl create namespace interview-test --dry-run=none
kubectl config set-context --current --namespace=interview-test
kubectl create serviceaccount dima-dev
kubectl create role admin-ns --verb=\* --resource=\*
kubectl create rolebinding dima-dev-admin-ns --role=admin-ns --serviceaccount=interview-test:dima-dev
kubectl create clusterrolebinding dima-dev-cluster-admin --clusterrole=admin --serviceaccount=interview-test:dima-dev
kubectl describe clusterrolebinding sa dima-dev
kubectl get secret --namespace=interview-test
kubectl get secret dima-dev-token-8x66c -o yaml
kubectl describe secret dima-dev-token-8x66c

kubectl get HorizontalPodAutoscaler -o yaml
kubectl get deployment -o yaml

kubectl get rolebinding
kubectl get rolebinding -o yaml
kubectl get clusterrolebinding

kubectl delete rolebinding dima-dev-admin
kubectl delete clusterrolebinding dima-dev-cluster-admin