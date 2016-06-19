Module 6 - Cluster management with Kubernetes
=============================================

This module focuses on the benefits of using a cluster management tool to run and maintain distributed applications as containers with Kubernetes

You will learn about:
---------------------

* Multi-host deployment
* Load-balancing
* Rolling updates and rollback
* Self-healing infrasctructure
* Management of secrets and configuration for containers


# TODO

Update the authoring environment:

* add the docker images listed in `./kubernetes/docker-images.txt`. Update the 2 `docker-images.txt` files in https://github.com/ThoughtWorksInc/dockerprod-auth-env/
* provision the VMs with `./kube-cluster/kubernetes_client.sh`
* verify/add VBox port mappings on the master VM (8080, 9090, 30061 ?)
* rebuild the different boxes: `vagrant up`, `vagrant package --output workshop[2].box`

Module:
* create the script up.sh (clean all running containers)
* create the script down.sh (clean all Kubernetes running containers, stop the cluster, restart Docker with the default configuration)
* take inspiration of other modules for scripts organization (source/export common variables and other scripts, ...)
* replace examples with the busmeme app by examples with the shop-app app

Start
-----

Configure the environment for **Module 6 - Start state**

```sh
cd ~/topics/start/module6
./up.sh
```

<a name="exercise1" />

Exercise 1 of 13 - Start Kubernetes
-----------------------------------

In the VM named `workshop`, run the following script:

  * `./kube-cluster/start_kubernetes_master.sh`

Wait for the end of the previous installation. Then, in the VM named `workshop-second-host`, run the following script:

  * `./kube-cluster/start_kubernetes_node.sh`

Verify if the Kubernetes API is accessible:

```
$ curl http://localhost:8080
{
  "paths": [
    "/api",
    "/api/v1",
    "/apis",
    "/apis/autoscaling",
    "/apis/autoscaling/v1",
    "/apis/batch",
    "/apis/batch/v1",
    "/apis/extensions",
    "/apis/extensions/v1beta1",
    "/healthz",
    "/healthz/ping",
    "/logs/",
    "/metrics",
    "/resetMetrics",
    "/swagger-ui/",
    "/swaggerapi/",
    "/ui/",
    "/version"
  ]
}
```

or visit [http://192.168.33.10:8080/](http://192.168.33.10:8080)

<a name="exercise2" />

Exercise 2 of 13 - Master status
--------------------------------

From the VM named `workshop`, check the status of our new Kubernetes cluster with the `kubectl` CLI tool:

```
$ kubectl cluster-info
Kubernetes master is running at http://localhost:8080
```

```
$ kubectl api-versions
autoscaling/v1
batch/v1
extensions/v1beta1
v1
```

```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"2", GitVersion:"v1.2.1", GitCommit:"50809107cd47a1f62da362bccefdd9e6f7076145", GitTreeState:"clean"}
Server Version: version.Info{Major:"1", Minor:"2", GitVersion:"v1.2.1", GitCommit:"50809107cd47a1f62da362bccefdd9e6f7076145", GitTreeState:"clean"}
```

For more advanced details about the cluster startup, run:

```
$ kubectl get events
```

<a name="exercise3" />

Exercise 3 of 13 - Node status
------------------------------

From the VM named `workshop-second-host`, try one of the previous commands but with the additional option `-s`.
Example:

```
$ kubectl -s http://localhost:8080 cluster-info
```

If the command is successfull, this means that the node is able to establish a communication with the master.

A better way to confirm this information is to run:

```
$ kubectl get nodes
NAME                   STATUS    AGE
127.0.0.1              Ready     20m
workshop-second-host   Ready     10s
```

For the following exercises, open a new separated terminal and always keep this command running:

```
$ watch kubectl get rc,svc,pods --all-namespaces=true -o wide
```

This command will help us to monitor the state of Kubernetes and all the components running in the cluster.

<a name="exercise4" />

Exercise 4 of 13 - Kubernetes dashboard
---------------------------------------

Run:

```
$ docker run\
    --net=host\
    --rm\
    -it\
        gcr.io/google_containers/kubernetes-dashboard-amd64:v1.1.0-beta3\
            --apiserver-host http://192.168.33.10:8080
```

And go to `http://localhost:9090/`



<a name="exercise5" />

Exercise 5 of 13 - Create a pod, mono-container
-----------------------------------------------

TODO: this example is not working

Start 1 container in 1 POD:

```
$ kubectl run my-nginx --image=nginx --port 9090
$ kubectl expose pod my-nginx --port=9090 --external-ip=192.168.33.10
```

Inspect the POD configuration / status:

```
$ kubectl describe pod my-nginx
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
* exposed the ports' container on 80/TCP
* affected an internal IP for the POD inside the cluster
* the base image used is `0d409d33b27e47423b049f7f863faa08655a8c901749c2b25b93ca67d01a470d` which is our nginx image (see `docker images | grep nginx`)

Access the application by visiting: `http://localhost:9090`

<a name="exercise6" />

Exercise 6 of 13 - Create a pod, multi containers
-------------------------------------------------

Start N containers in 1 POD

```
$ kubectl delete pod busmeme
$ kubectl create -f ./kubernetes/kube-templates/pods-multihost/busmeme-rc.yml
$ kubectl describe pod busmeme
```

<div class="info-box information">
* All the containers inside a POD share the same network network
* Within a Pod, each container can reach an other container ports on localhost
</div>

Expose the POD outside the cluster:

```
$ kubectl create -f ./kubernetes/kube-templates/pods-multihost/busmeme-service.yml
```

Visit [http://192.168.33.10:30061/](http://192.168.33.10:30061/)

<a name="exercise7" />

Exercise 7 of 13 - Debugging
----------------------------

Show the logs of each container running in the POD:

```
$ kubectl logs [POD-NAME] mongo
$ kubectl logs [POD-NAME] web
```

Attach the standard out (stdout) of a container:

```
kubectl attach -i [pod-name]
```

Execute a command inside a POD:

```
$ kubectl exec [POD-NAME] date
$ kubectl exec [POD-NAME] ls
$ kubectl exec [POD-NAME] echo $PATH
```

<a name="exercise8" />

Exercise 8 of 13 - Update a POD
-------------------------------

From the [interface](http://localhost:9090), try to change the Docker image.
After an automatic redeployment, the change should be reflected "immedialy".

Apply now the same change by editing the file `busmeme-rc.yml` 

```
$ kubectl apply -f./kubernetes/kube-templates/pods-multihost/busmeme-rc.yml
```

Note: pod updates may not change fields other than `containers[*].image` or `spec.activeDeadlineSeconds`


<a name="exercise9" />

Exercise 9 of 13 - Rolling updates and rollbacks
------------------------------------------------


kubectl create -f lbapp-svc.yml

1. Release 1

```
$ kubectl create -f lbapp-v1-deployment.yml
$ kubectl rollout history deployment/lbapp-deployment
```

2. Release 2 (update)
 
Change the label:

```
$ kubectl apply -f lbapp-v2-deployment.yml
$ kubectl rollout history deployment/lbapp-deployment
```

3. Rollback

```
$ kubectl rollout undo deployment/lbapp-deployment --to-revision=1
```

<a name="exercise10" />

Exercise 10 of 13 - Load balancing
----------------------------------

Check endpoints:

```
$ kubectl describe svc busmeme-service
Name:			busmeme-service
Namespace:		default
Labels:			name=web
Selector:		name=web
Type:			NodePort
IP:			10.0.0.48
Port:			<unset>	4000/TCP
NodePort:		<unset>	30061/TCP
Endpoints:		10.1.14.2:3000,10.1.55.2:3000
Session Affinity:	None
No events.
```

<a name="exercise11" />

Exercise 11 of 13 - Secrets
---------------------------

```
$ kubectl create secret generic lbapp-db --from-literal='lbapp-dbuser=produser' --from-literal='lbapp-dbpwd=twkubernetes'
$ kubectl get secrets
```

<a name="exercise12" />

Exercise 12 of 13 - Self-healing
--------------------------------

```
$ kubectl create -f lb-app-probe.yml
```

Check the status of one of the pods

```
 FirstSeen	LastSeen	Count	From				SubobjectPath			Type		Reason			Message
  ---------	--------	-----	----				-------------			--------	------			-------
  3m		3m		1	{default-scheduler }						Normal		Scheduled		Successfully assigned lbapp-rc-m2eoe to workshop-second-host
  3m		3m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Started			Started container with docker id 7dc6893a5f79
  3m		3m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Created			Created container with docker id 7dc6893a5f79
  2m		2m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Killing			Killing container with docker id 7dc6893a5f79: pod "lbapp-rc-m2eoe_default(755cd7f6-3387-11e6-ac39-080027048954)" container "liveness" is unhealthy, it will be killed and re-created.
  2m		2m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Created			Created container with docker id eade5a04a45f
  2m		2m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Started			Started container with docker id eade5a04a45f
  1m		1m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Killing			Killing container with docker id eade5a04a45f: pod "lbapp-rc-m2eoe_default(755cd7f6-3387-11e6-ac39-080027048954)" container "liveness" is unhealthy, it will be killed and re-created.
  1m		1m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Started			Started container with docker id 95e53548eef4
  1m		1m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Created			Created container with docker id 95e53548eef4
  1m		1m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Killing			Killing container with docker id 95e53548eef4: pod "lbapp-rc-m2eoe_default(755cd7f6-3387-11e6-ac39-080027048954)" container "liveness" is unhealthy, it will be killed and re-created.
  1m		1m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Started			Started container with docker id 00524bc95109
  1m		1m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Created			Created container with docker id 00524bc95109
  3m		36s		5	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Pulling			pulling image "willgarcia/lb-app"
  36s		36s		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Killing			Killing container with docker id 00524bc95109: pod "lbapp-rc-m2eoe_default(755cd7f6-3387-11e6-ac39-080027048954)" container "liveness" is unhealthy, it will be killed and re-created.
  30s		30s		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Started			Started container with docker id 2e61ea30e7f4
  3m		30s		5	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Pulled			Successfully pulled image "willgarcia/lb-app"
  3m		30s		6	{kubelet workshop-second-host}					Warning		MissingClusterDNS	kubelet does not have ClusterDNS IP configured and cannot create Pod using "ClusterFirst" policy. Falling back to DNSDefault policy.
  30s		30s		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Created			Created container with docker id 2e61ea30e7f4
  3m		26s		7	{kubelet workshop-second-host}	spec.containers{liveness}	Warning		Unhealthy		Liveness probe failed: cat: /tmp/lbapp.lock: No such file or directory
```

Health check is configured to verify the presence of this file inside the container: /tmp/lbapp.lock


Add the following lines to ....

```
livenessProbe:
     exec:
       command:
         - cat
         - /tmp/lbapp.lock
     initialDelaySeconds: 15
     timeoutSeconds: 1
   name: liveness
```

File is missing, as a result the pod is flagged as unhealthy and after a certain amount of retries, its status goes from Running to CrashLoopBackOff

```
  FirstSeen	LastSeen	Count	From				SubobjectPath			Type		Reason		Message
  ---------	--------	-----	----				-------------			--------	------		-------
  6m		6m		1	{default-scheduler }						Normal		Scheduled	Successfully assigned lbapp-rc-m2eoe to workshop-second-host
  6m		6m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Started		Started container with docker id 7dc6893a5f79
  6m		6m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Created		Created container with docker id 7dc6893a5f79
  6m		6m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Killing		Killing container with docker id 7dc6893a5f79: pod "lbapp-rc-m2eoe_default(755cd7f6-3387-11e6-ac39-080027048954)" container "liveness" is unhealthy, it will be killed and re-created.
  6m		6m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Created		Created container with docker id eade5a04a45f
  5m		5m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Started		Started container with docker id eade5a04a45f
  5m		5m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Killing		Killing container with docker id eade5a04a45f: pod "lbapp-rc-m2eoe_default(755cd7f6-3387-11e6-ac39-080027048954)" container "liveness" is unhealthy, it will be killed and re-created.
  5m		5m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Created		Created container with docker id 95e53548eef4
  5m		5m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Started		Started container with docker id 95e53548eef4
  4m		4m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Killing		Killing container with docker id 95e53548eef4: pod "lbapp-rc-m2eoe_default(755cd7f6-3387-11e6-ac39-080027048954)" container "liveness" is unhealthy, it will be killed and re-created.
  4m		4m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Created		Created container with docker id 00524bc95109
  4m		4m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Started		Started container with docker id 00524bc95109
  4m		4m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Killing		Killing container with docker id 00524bc95109: pod "lbapp-rc-m2eoe_default(755cd7f6-3387-11e6-ac39-080027048954)" container "liveness" is unhealthy, it will be killed and re-created.
  3m		3m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Started		Started container with docker id 2e61ea30e7f4
  3m		3m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Created		Created container with docker id 2e61ea30e7f4
  3m		3m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Killing		Killing container with docker id 2e61ea30e7f4: pod "lbapp-rc-m2eoe_default(755cd7f6-3387-11e6-ac39-080027048954)" container "liveness" is unhealthy, it will be killed and re-created.
  3m		3m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Started		Started container with docker id 81f4637ec038
  3m		3m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Created		Created container with docker id 81f4637ec038
  2m		2m		1	{kubelet workshop-second-host}	spec.containers{liveness}	Normal		Killing		Killing container with docker id 81f4637ec038: pod "lbapp-rc-m2eoe_default(755cd7f6-3387-11e6-ac39-080027048954)" container "liveness" is unhealthy, it will be killed and re-created.
  2m		1m		8	{kubelet workshop-second-host}					Warning		FailedSync	Error syncing pod, skipping: failed to "StartContainer" for "liveness" with CrashLoopBackOff: "Back-off 1m20s restarting failed container=liveness pod=lbapp-rc-m2eoe_default(755cd7f6-3387-11e6-ac39-080027048954)"
```


<a name="exercise13" />

Exercise 13 of 13 - Add-ons
---------------------------

https://github.com/kubernetes/kubernetes/tree/master/cluster/addons
https://github.com/kubernetes/kubedash


Tutorial/Help docs
------------------

* https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md#action-required
* http://kubernetes.io/docs/user-guide/accessing-the-cluster/#accessing-the-cluster-api
* http://kubernetes.io/docs/user-guide/kubectl/kubectl/
http://kubernetes.io/docs/user-guide/kubectl/kubectl_exec/
* http://kubernetes.io/docs/user-guide/configuring-containers/#configuration-in-kubernetes
* http://kubernetes.io/docs/user-guide/walkthrough/#kubectl-cli
* http://kubernetes.io/docs/user-guide/ui/
* http://kubernetes.io/docs/getting-started-guides/docker-multinode/master/
* http://kubernetes.io/docs/getting-started-guides/docker-multinode/worker/
* http://kubernetes.io/docs/admin/node/#what-is-a-node

* http://kubernetes.io/docs/user-guide/pods/multi-container/
* http://kubernetes.io/docs/user-guide/deployments/#what-is-a-deployment
* http://kubernetes.io/docs/user-guide/debugging-pods-and-replication-controllers/
* https://github.com/kubernetes/kubernetes/wiki/Debugging-FAQ
* http://kubernetes.io/docs/user-guide/walkthrough/k8s201/
* http://kubernetes.io/docs/user-guide/labels/#motivation
* http://kubernetes.io/docs/user-guide/replication-controller/#what-is-a-replication-controller
* http://kubernetes.io/docs/user-guide/production-pods/#resource-management
* http://kubernetes.io/docs/user-guide/production-pods/#liveness-and-readiness-probes-aka-health-checks
* https://github.com/kubernetes/kubernetes/blob/release-1.3/docs/design/secrets.md

Examples
--------

* https://github.com/kubernetes/kubernetes/tree/master/examples
* https://github.com/kubernetes/kubernetes/tree/release-1.2/examples/guestbook/
* http://kubernetes.io/docs/user-guide/update-demo/
* http://kubernetes.io/docs/user-guide/services/#type-loadbalancer
* http://kubernetes.io/docs/user-guide/deploying-applications/

