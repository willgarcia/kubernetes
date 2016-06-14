#!/bin/bash


kubectl delete rc kubernetes-dashboard-v1.1.0-beta2 --namespace=kube-system
kubectl delete svc kubernetes-dashboard --namespace=kube-system

kubectl create -f ns-kube-system.yml
kubectl create -f dashboard-controller.yaml --namespace=kube-system
kubectl create -f dashboard-service.yaml --namespace=kube-system
