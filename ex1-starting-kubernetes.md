# First Kubernetes cluster

## 1. Create the cluster

TODO:
- update the authoring environment to add some docker images. search `docker-images.txt` files in https://github.com/ThoughtWorksInc/dockerprod-auth-env/
- rebuild the different boxes: `vagrant up`, `vagrant package --output workshop[2].box`

DONE
- Create a script `start_kubernetes.sh` to automate this installation

http://kubernetes.io/docs/getting-started-guides/docker-multinode/master/
http://kubernetes.io/docs/getting-started-guides/docker-multinode/worker/
http://kubernetes.io/docs/admin/node/#what-is-a-node


## 3. Clients installation

### Kube-dashboard

See: http://kubernetes.io/docs/user-guide/ui/ + http://kubernetes.io/docs/user-guide/ui-access/

docker run --net=host --rm -it gcr.io/google_containers/kubernetes-dashboard-amd64:v1.1.0-beta3 --apiserver-host http://192.168.33.10:8080

Go to `http://localhost:9090/#/workload`

TODO
kubectl run --port=9090 --image=gcr.io/google_containers/kubernetes-dashboard-amd64:v1.1.0-beta3 mydashboard -- --apiserver-host http://192.168.33.10:8080

### Kubectl CLI

Example of basic commands:


* Explain the following commands:

```
kubectl cluster-info
kubectl -s http://localhost:8080 cluster-info
kubectl get events
kubectl api-versions
kubectl version
kubectl get rc,svc,pods --all-namespaces=true -o wide
```

http://192.168.33.10:8080/

see http://kubernetes.io/docs/user-guide/kubectl/kubectl/

Accessing the API / Web UI via a reverse proxy:

`kubectl -s http://192.168.33.10:8080/ proxy --port=8080`

http://kubernetes.io/docs/user-guide/accessing-the-cluster/#accessing-the-cluster-api