# Create a DEPLOYMENT

See http://kubernetes.io/docs/user-guide/walkthrough/k8s201/

## Update a pod

From the interface, change shop-app image version from `shop-app` to `shop-app:2.0.0`

From the CLI,

Edit the *.yml and update the version (copy this file) :

And run

`kubectl -s http://localhost:8080 apply -f busmeme-pod.yml`
`kubectl -s http://localhost:8080 delete busmeme-pod`


Check the version of your container in the web UI or with docker ps

Note: pod updates may not change fields other than `containers[*].image` or `spec.activeDeadlineSeconds`

## Rep controller

`kubectl -s http://localhost:8080 create -f busmeme-controller.yml`


Replications needed : pod “replicas” are running at any one time

http://kubernetes.io/docs/user-guide/labels/#motivation
http://kubernetes.io/docs/user-guide/replication-controller/#what-is-a-replication-controller

## Rolling update

kubectl create -f lbapp-svc.yml

## release 1

 kubectl create -f lbapp-v1-deployment.yml
 kubectl rollout history deployment/lbapp-deployment


 ### release 2 (update)
 Change the label:

kubectl apply -f lbapp-v2-deployment.yml
kubectl rollout history deployment/lbapp-deployment

### rollback

 kubectl rollout undo deployment/lbapp-deployment --to-revision=1




http://kubernetes.io/docs/user-guide/update-demo/


## Replication / scaling / load balancing


http://kubernetes.io/docs/user-guide/services/#type-loadbalancer
http://kubernetes.io/docs/user-guide/deploying-applications/

## Lifecycle management

TODO
* lifecycle management: restart policies, probes, health checks

Commands to highlight: `kubectl apply/edit/scale/patch/replace`