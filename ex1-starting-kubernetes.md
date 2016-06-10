# First Kubernetes cluster

## 1. Create the cluster


TODO:
- update the authoring environment to add some docker images. search `docker-images.txt` files in https://github.com/ThoughtWorksInc/dockerprod-auth-env/
- rebuild the different boxes: `vagrant up`, `vagrant package --output workshop[2].box`
- Create a script `start_kubernetes.sh` to automate this installation, see following commands:

```
docker stop $(docker ps -a -q)
docker rm -f $(docker ps -a -q)
docker run -d --net=host gcr.io/google_containers/etcd:2.0.12   /usr/local/bin/etcd   --addr=127.0.0.1:4001   --bind-addr=0.0.0.0:4001   --data-dir=/var/etcd/data
docker run -d   --volume=/:/rootfs:ro   --volume=/sys:/sys:ro   --volume=/dev:/dev   --volume=/var/lib/docker/:/var/lib/docker:ro   --volume=/var/lib/kubelet/:/var/lib/kubelet:rw   --volume=/var/run:/var/run:rw   --net=host   --pid=host   --privileged=true   gcr.io/google_containers/hyperkube:v1.0.1     /hyperkube kubelet     --containerized     --hostname-override="127.0.0.1"     --address="0.0.0.0"     --api-servers=http://localhost:8080     --config=/etc/kubernetes/manifests
docker run -d --net=host --privileged gcr.io/google_containers/hyperkube:v1.0.1   /hyperkube proxy   --master=http://127.0.0.1:8080   --v=2
until $(kubectl -s http://localhost:8080 cluster-info &> /dev/null); do
    sleep 1
done
```

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
