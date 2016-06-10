# First Kubernetes cluster

## 1. Create the cluster


TODO:
- update the authoring environment to add some docker images. search `docker-images.txt` files in https://github.com/ThoughtWorksInc/dockerprod-auth-env/
- rebuild the different boxes: `vagrant up`, `vagrant package --output workshop[2].box`

DONE
- Create a script `start_kubernetes.sh` to automate this installation

## 2. Cluster status

* Explain the following commands:

```
kubectl cluster-info
kubectl -s http://localhost:8080 cluster-info
kubectl get events
kubectl api-versions
```

## 3. Start Kube-UI

```
kubectl -s http://localhost:8080 create -f kube-ui-rc.yaml
kubectl -s http://localhost:8080 create -f kube-ui-svc.yaml --validate=false
```
## 4. Explain/show Kbe-UI navigation
