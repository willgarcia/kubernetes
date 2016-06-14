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


## 2. Cluster status

* Explain the following commands:

```
kubectl cluster-info
kubectl -s http://localhost:8080 cluster-info
kubectl get events
kubectl api-versions
```

## 3. Start Kube-dashboard


See: http://kubernetes.io/docs/user-guide/ui/ + http://kubernetes.io/docs/user-guide/ui-access/



Explain concept of:

### addons (https://github.com/kubernetes/kubernetes/blob/release-1.2/cluster/saltbase/salt/kube-addons/kube-addons.sh)



### namespaces

http://kubernetes.io/docs/admin/namespaces/ / Limitate visibility between groups inside the cluster, group/user management

always add option --namespace