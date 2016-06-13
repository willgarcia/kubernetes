# Create a POD

## 1. Declarative configuration / POD definition

TODO 

    * Basic of the YAML format / relation with Kubectl 
    * A POD is a set of container, smallest unit of work in Kubernetes, one of the types/kind of object ... (show kind attribute in a template ..)

See kubectl info CLI

* http://kubernetes.io/docs/user-guide/configuring-containers/#configuration-in-kubernetes
* http://kubernetes.io/docs/user-guide/walkthrough/#kubectl-cli

## 2. One container 

1. Start 1 container in 1 POD

```
kubectl run my-nginx --image=nginx --port 80
kubectl -s http://localhost:8080 expose rc my-nginx --port=80 --external-ip=192.168.99.103
```
2. Check the status of the POD

```
kubectl pods | grep nginx
```

3. Inspect the POD configuration / status:

`kubectl describe pod my-nginx-erhhc`


```
Name:		my-nginx-erhhc
Namespace:	default
Node:		127.0.0.1/127.0.0.1
Start Time:	Fri, 10 Jun 2016 15:11:31 +1000
Labels:		run=my-nginx
Status:		Running
IP:		172.17.0.2
Controllers:	ReplicationController/my-nginx
Containers:
  my-nginx:
    Container ID:	docker://655f3949fa48277a38d970fd4dfc980415a57ec9368cb81fa2eb30c107fcee16
    Image:		nginx
    Image ID:		docker://sha256:0d409d33b27e47423b049f7f863faa08655a8c901749c2b25b93ca67d01a470d
    Port:		80/TCP
    QoS Tier:
      cpu:		BestEffort
      memory:		BestEffort
    State:		Running
      Started:		Fri, 10 Jun 2016 15:11:53 +1000
    Ready:		True
    Restart Count:	0
    Environment Variables:
Conditions:
  Type		Status
  Ready 	True
No volumes.
Events:
  FirstSeen	LastSeen	Count	From			SubobjectPath				Type		Reason		Message
  ---------	--------	-----	----			-------------				--------	------		-------
  16m		16m		1	{scheduler }									scheduled	Successfully assigned my-nginx-erhhc to 127.0.0.1
  16m		16m		1	{kubelet 127.0.0.1}	implicitly required container POD			pulled		Pod container image "gcr.io/google_containers/pause:0.8.0" already present on machine
  16m		16m		1	{kubelet 127.0.0.1}	implicitly required container POD			created		Created with docker id 1c67430bf3d2
  16m		16m		1	{kubelet 127.0.0.1}	implicitly required container POD			started		Started with docker id 1c67430bf3d2
  16m		16m		1	{kubelet 127.0.0.1}								failedSync	Error syncing pod, skipping: DNS ResolvConfPath specified but does not exist. It could not be updated: /mnt/sda1/var/lib/docker/containers/1c67430bf3d2d238f2b10dcd139730059e89cc47fe43143011dc8d0af37ad453/resolv.conf
  16m		16m		1	{kubelet 127.0.0.1}	spec.containers{my-nginx}				pulled		Successfully pulled image "nginx"
  16m		16m		1	{kubelet 127.0.0.1}	spec.containers{my-nginx}				created		Created with docker id 655f3949fa48
  16m		16m		1	{kubelet 127.0.0.1}	spec.containers{my-nginx}				started		Started with docker id 655f3949fa48
```

By reading these details, we understand that Kubernetes:
* created a new container with the ID `655f3949fa48` - see Event sections
* the base image used is `0d409d33b27e47423b049f7f863faa08655a8c901749c2b25b93ca67d01a470d` which is our nginx image (docker images | grep nginx)
* exposed the ports' container on 80/TCP
*

3. Access the application

Go to: `http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/kube-ui/#/dashboard/pods/my-nginx-erhhc`

* The pod my-nginx-* should be running on port 80
* Nginx should be accessible on (http://localhost:8080)[http://localhost:8080]

4. Volumes

see /data/db ...

5. Simulate a failure

docker kill mongo

kubectl get rc,svc,pods,nodes

wait for the container to spin up automatically


Basic configuration:
* environment variables
* port
* names

TODO: Nginx example

## 3. Multi-containers

Start N containers in 1 POD


kubectl delete pod busmeme
kubectl -s http://localhost:8080 create -f busmeme-pod.yml
kubectl describe pod busmeme

Basic configuration
* volumes
* "link" with an other container in the same POD

All the containers inside a POD are under the same network

TODO: Example with shop-app/catalog/review

See current example with Busmeme: `busmeme-pod.yml`

```
kubectl delete pod busmeme
kubectl -s http://localhost:8080 create -f busmeme-pod.yml
kubectl describe pod busmeme

#kubectl logs busmeme mongo or web
```
