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

Step 1 of 13 - Start Kubernetes
-----------------------------------

This tutorial uses the Docker for Mac - edge version to run the cluster:

```
kubectl config get-contexts
kubectl config use-context docker-for-deskto
```

Step 2 of 13 - Master status
--------------------------------

Check the status of our new Kubernetes cluster with the `kubectl` CLI tool:

```
$ kubectl cluster-info
Kubernetes master is running at https://localhost:6443
KubeDNS is running at https://localhost:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

```
$ kubectl api-versions
admissionregistration.k8s.io/v1beta1
apiextensions.k8s.io/v1beta1
apiregistration.k8s.io/v1beta1
apps/v1
apps/v1beta1
apps/v1beta2
authentication.k8s.io/v1
authentication.k8s.io/v1beta1
authorization.k8s.io/v1
authorization.k8s.io/v1beta1
autoscaling/v1
autoscaling/v2beta1
batch/v1
batch/v1beta1
certificates.k8s.io/v1beta1
compose.docker.com/v1beta1
compose.docker.com/v1beta2
events.k8s.io/v1beta1
extensions/v1beta1
networking.k8s.io/v1
policy/v1beta1
rbac.authorization.k8s.io/v1
rbac.authorization.k8s.io/v1beta1
storage.k8s.io/v1
storage.k8s.io/v1beta1
v1
```

```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"9", GitVersion:"v1.9.6", GitCommit:"9f8ebd171479bec0ada837d7ee641dec2f8c6dd1", GitTreeState:"clean", BuildDate:"2018-03-21T15:21:50Z", GoVersion:"go1.9.3", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"9", GitVersion:"v1.9.6", GitCommit:"9f8ebd171479bec0ada837d7ee641dec2f8c6dd1", GitTreeState:"clean", BuildDate:"2018-03-21T15:13:31Z", GoVersion:"go1.9.3", Compiler:"gc", Platform:"linux/amd64"}
```

For more details about the cluster events happening during the startup process, run:

```
$ kubectl get events
```

Step 3 of 13 - Node status
------------------------------

Run one of the previous commands  with the Kubectl option `-s`.
Example:

```
$ kubectl --server https://localhost:6443 cluster-info
```

If the command is successfull, this means that the node is able to establish a communication with the master.

A better way to confirm this information is to run:

```
$ kubectl get nodes
NAME                 STATUS    ROLES     AGE       VERSION
docker-for-desktop   Ready     master    8m        v1.9.6
```


Step 4 of 13 - Kubernetes dashboard
---------------------------------------

Run:

```
$ kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
$ kubectl proxy
```

And go to `http://localhost:8001/` to browse all the Kubernetes API endpoints available or directly to ``http://localhost:8001/ui` to visit the UI dashboard:

```
{
  "paths": [
    "/api",
    "/api/v1",
    "/apis",
    "/apis/",
    "/apis/admissionregistration.k8s.io",
    "/apis/admissionregistration.k8s.io/v1beta1",
    "/apis/apiextensions.k8s.io",
    "/apis/apiextensions.k8s.io/v1beta1",
    "/apis/apiregistration.k8s.io",
    "/apis/apiregistration.k8s.io/v1beta1",
    "/apis/apps",
    "/apis/apps/v1",
    "/apis/apps/v1beta1",
    "/apis/apps/v1beta2",
    "/apis/authentication.k8s.io",
    "/apis/authentication.k8s.io/v1",
    "/apis/authentication.k8s.io/v1beta1",
    "/apis/authorization.k8s.io",
    "/apis/authorization.k8s.io/v1",
    "/apis/authorization.k8s.io/v1beta1",
    "/apis/autoscaling",
    "/apis/autoscaling/v1",
    "/apis/autoscaling/v2beta1",
    "/apis/batch",
    "/apis/batch/v1",
    "/apis/batch/v1beta1",
    "/apis/certificates.k8s.io",
    "/apis/certificates.k8s.io/v1beta1",
    "/apis/compose.docker.com",
    "/apis/compose.docker.com/v1beta1",
    "/apis/compose.docker.com/v1beta2",
    "/apis/events.k8s.io",
    "/apis/events.k8s.io/v1beta1",
    "/apis/extensions",
    "/apis/extensions/v1beta1",
    "/apis/networking.k8s.io",
    "/apis/networking.k8s.io/v1",
    "/apis/policy",
    "/apis/policy/v1beta1",
    "/apis/rbac.authorization.k8s.io",
    "/apis/rbac.authorization.k8s.io/v1",
    "/apis/rbac.authorization.k8s.io/v1beta1",
    "/apis/storage.k8s.io",
    "/apis/storage.k8s.io/v1",
    "/apis/storage.k8s.io/v1beta1",
    "/healthz",
    "/healthz/autoregister-completion",
    "/healthz/etcd",
    "/healthz/ping",
    "/healthz/poststarthook/apiservice-openapi-controller",
    "/healthz/poststarthook/apiservice-registration-controller",
    "/healthz/poststarthook/apiservice-status-available-controller",
    "/healthz/poststarthook/bootstrap-controller",
    "/healthz/poststarthook/ca-registration",
    "/healthz/poststarthook/generic-apiserver-start-informers",
    "/healthz/poststarthook/kube-apiserver-autoregistration",
    "/healthz/poststarthook/rbac/bootstrap-roles",
    "/healthz/poststarthook/start-apiextensions-controllers",
    "/healthz/poststarthook/start-apiextensions-informers",
    "/healthz/poststarthook/start-kube-aggregator-informers",
    "/healthz/poststarthook/start-kube-apiserver-informers",
    "/logs",
    "/metrics",
    "/swagger-2.0.0.json",
    "/swagger-2.0.0.pb-v1",
    "/swagger-2.0.0.pb-v1.gz",
    "/swagger.json",
    "/swaggerapi",
    "/ui",
    "/ui/",
    "/version"
  ]
}
```

Step 5 of 13 - Create a pod, multi-containers load balanced
-----------------------------------------------------------

For the following exercises, we are going to create a Kubernetes namespace to run our services:

```
$ kubectl create namespace my-nginx
```

And we will watch all the resources (pods, deployments, services) we create within this new Kubernetes namespace. Open a new separated terminal and always keep this command running:

```
$ watch kubectl get rc,svc,pods -n my-nginx
```

This command will help us to follow the state of Kubernetes and all the components running in the part of the cluster we are interested in.

Start 1 container in 1 POD:

```
$ kubectl run my-nginx --image=nginx --replicas=3 -n my-nginx --port 80
deployment "my-nginx" created
```

Get information about the deployment:

```
$ kubectl get deployments my-nginx -n my-nginx
NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
my-nginx   3         3         3            3           33s

$ kubectl describe deployments my-nginx -n my-nginx
Name:                   my-nginx
Namespace:              my-nginx
CreationTimestamp:      Tue, 22 May 2018 20:38:05 +1000
Labels:                 run=my-nginx
Annotations:            deployment.kubernetes.io/revision=1
Selector:               run=my-nginx
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:  run=my-nginx
  Containers:
   my-nginx:
    Image:        nginx
    Port:         9090/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   my-nginx-65d8484c4b (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  45s   deployment-controller  Scaled up replica set my-nginx-65d8484c4b to 3
  ```

Display additional information about the replica set:

```
$ kubectl get replicasets -n my-nginx
NAME                  DESIRED   CURRENT   READY     AGE
my-nginx-65d8484c4b   3         3         3         1m

$ kubectl describe replicasets -n my-nginx
NAME                  DESIRED   CURRENT   READY     AGE
my-nginx-65d8484c4b   3         3         3         1m
Williams-MBP-2% kubectl describe replicasets -n my-nginx
Name:           my-nginx-65d8484c4b
Namespace:      my-nginx
Selector:       pod-template-hash=2184040706,run=my-nginx
Labels:         pod-template-hash=2184040706
                run=my-nginx
Annotations:    deployment.kubernetes.io/desired-replicas=3
                deployment.kubernetes.io/max-replicas=4
                deployment.kubernetes.io/revision=1
Controlled By:  Deployment/my-nginx
Replicas:       3 current / 3 desired
Pods Status:    3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  pod-template-hash=2184040706
           run=my-nginx
  Containers:
   my-nginx:
    Image:        nginx
    Port:         9090/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  1m    replicaset-controller  Created pod: my-nginx-65d8484c4b-zm44x
  Normal  SuccessfulCreate  1m    replicaset-controller  Created pod: my-nginx-65d8484c4b-w8xnt
  Normal  SuccessfulCreate  1m    replicaset-controller  Created pod: my-nginx-65d8484c4b-5wbpb
```

Create service to expose the deployment:

````
$ kubectl expose deployment my-nginx --port 9000 --target-port 80 --type=LoadBalancer --name=my-nginx -n my-nginx
service "my-service" exposed
```

Describe the service created:

```
$ kubectl get services my-nginx -n my-nginx
NAME       TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
my-nginx   LoadBalancer   10.97.113.142   localhost     9000:31614/TCP   22s

$ kubectl describe services my-nginx -n my-nginx
Name:                     my-nginx
Namespace:                my-nginx
Labels:                   run=my-nginx
Annotations:              <none>
Selector:                 run=my-nginx
Type:                     LoadBalancer
IP:                       10.97.113.142
LoadBalancer Ingress:     localhost
Port:                     <unset>  9000/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  31614/TCP
Endpoints:                10.1.0.24:80,10.1.0.25:80,10.1.0.26:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

`localhost` is the external IP of the cluster.
`9000` is the port exposed by the cluster and points to internal nginx instances running on 80

Inspect the POD configuration / status:

```
$ kubectl get pods -n my-nginx
NAME                        READY     STATUS    RESTARTS   AGE
my-nginx-65d8484c4b-5wbpb   1/1       Running   0          7m
my-nginx-65d8484c4b-w8xnt   1/1       Running   0          7m
my-nginx-65d8484c4b-zm44x   1/1       Running   0          7m
```

Access the nginx welcome page with: 

```
$ curl http://localhost:9000
```

Delete all nginx resources in the cluster:

```
kubectl delete svc,po,deploy my-nginx -n my-nginx
```

Step 6 of 13 - Create a pod, multi containers, use a template
-------------------------------------------------------------

Similarly to the previous step, create a Kubernetes namespace:

```
$ kubectl create namespace my-app
$ watch kubectl get rc,svc,pods -n my-app
```

Start N containers in 1 POD

```
$ kubectl create -f ./kubernetes/kube-templates/pods-multihost/busmeme-rc.yml -n my-app
replicationcontroller "busmeme-rc" created

$ kubectl describe pod busmeme -n my-app
Name:           busmeme-rc-2x46l
Namespace:      my-app
Node:           docker-for-desktop/192.168.65.3
Start Time:     Tue, 22 May 2018 21:08:02 +1000
Labels:         name=web
Annotations:    <none>
Status:         Pending
IP:
Controlled By:  ReplicationController/busmeme-rc
Containers:
  mongo:
    Container ID:
    Image:          mongo
    Image ID:
    Port:           27017/TCP
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /data/db from mongo-persistent-storage (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-2h5rd (ro)
  web:
    Container ID:
    Image:          minillinim/busmemegenerator
    Image ID:
    Port:           3000/TCP
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Environment:
      NODE_ENV:        production
      TL_USER:         uSERnAME
      TL_PASSWORD:     pASSwORD
      PORT:            3000
      BM_MONGODB_URI:  mongodb://localhost/app-toto
      BM_ADMIN_TOKEN:  test
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-2h5rd (ro)
Conditions:
  Type           Status
  Initialized    True
  Ready          False
  PodScheduled   True
Volumes:
  mongo-persistent-storage:
    Type:          HostPath (bare host directory volume)
    Path:          /data/db
    HostPathType:
  default-token-2h5rd:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-2h5rd
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason                 Age   From                         Message
  ----    ------                 ----  ----                         -------
  Normal  Scheduled              13s   default-scheduler            Successfully assigned busmeme-rc-2x46l to docker-for-desktop
  Normal  SuccessfulMountVolume  13s   kubelet, docker-for-desktop  MountVolume.SetUp succeeded for volume "mongo-persistent-storage"
  Normal  SuccessfulMountVolume  13s   kubelet, docker-for-desktop  MountVolume.SetUp succeeded for volume "default-token-2h5rd"
  Normal  Pulling                11s   kubelet, docker-for-desktop  pulling image "mongo"

Name:           busmeme-rc-ssjrx
Namespace:      my-app
Node:           <none>
Labels:         name=web
Annotations:    <none>
Status:         Pending
IP:
Controlled By:  ReplicationController/busmeme-rc
Containers:
  mongo:
    Image:        mongo
    Port:         27017/TCP
    Environment:  <none>
    Mounts:
      /data/db from mongo-persistent-storage (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-2h5rd (ro)
  web:
    Image:  minillinim/busmemegenerator
    Port:   3000/TCP
    Environment:
      NODE_ENV:        production
      TL_USER:         uSERnAME
      TL_PASSWORD:     pASSwORD
      PORT:            3000
      BM_MONGODB_URI:  mongodb://localhost/app-toto
      BM_ADMIN_TOKEN:  test
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-2h5rd (ro)
Conditions:
  Type           Status
  PodScheduled   False
Volumes:
  mongo-persistent-storage:
    Type:          HostPath (bare host directory volume)
    Path:          /data/db
    HostPathType:
  default-token-2h5rd:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-2h5rd
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason            Age               From               Message
  ----     ------            ----              ----               -------
  Warning  FailedScheduling  6s (x5 over 13s)  default-scheduler  0/1 nodes are available: 1 PodFitsHostPorts.
```

All the containers inside a POD share the same network network.
Within a Pod, each container can reach an other container ports on localhost.

Expose the POD outside the cluster:

```
$ kubectl create -f ./kubernetes/kube-templates/pods-multihost/busmeme-service.yml -n my-app
service "busmeme-service" created
```

Describe the service created:

```
$ kubectl describe svc busmeme-service -n my-app
Name:                     busmeme-service
Namespace:                my-app
Labels:                   name=web
Annotations:              <none>
Selector:                 name=web
Type:                     NodePort
IP:                       10.102.226.221
LoadBalancer Ingress:     localhost
Port:                     <unset>  3000/TCP
TargetPort:               3000/TCP
NodePort:                 <unset>  30061/TCP
Endpoints:                10.1.0.28:3000
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

Visit [http://localhost:30061/](http://localhost:30061/)


Step 7 of 13 - Debugging
----------------------------

Show the logs of each container running in the POD:

```
$ kubectl logs [POD-NAME] mongo -n my-app
$ kubectl logs [POD-NAME] web -n my-app
```

Attach the standard out (stdout) of a container:

```
kubectl attach -i [POD-NAME]
```

Execute a command inside a POD:

```
$ kubectl exec [POD-NAME] date
$ kubectl exec [POD-NAME] ls
$ kubectl exec [POD-NAME] echo $PATH
```



Step 8 of 13 - Update a POD
-------------------------------

From the Kubernetes dashboard, try to change the Docker image.
After an automatic redeployment, the change should be reflected "immediately".

Apply now the same change by editing the file `busmeme-rc.yml` 

```
$ kubectl apply -f./kubernetes/kube-templates/pods-multihost/busmeme-rc.yml -n my-app
```

Note: pod updates may not change fields other than `containers[*].image` or `spec.activeDeadlineSeconds`


Step 9 of 13 - Rolling updates and rollbacks
------------------------------------------------

Create a new service for the application `LBAPP`

```
$ kubectl create -f kubernetes/kube-templates/rolling-update/lbapp-svc.yml -n my-app
service "lbapp-service" created
```

Release 1:

```
$ kubectl create -f kubernetes/kube-templates/rolling-update/lbapp-v1-deployment.yml -n my-app
deployment "lbapp-deployment" created

$ kubectl rollout history deployment/lbapp-deployment -n my-app
deployments "lbapp-deployment"
REVISION  CHANGE-CAUSE
1         <none>
```

The application LBAPP should display the current version of the application (version 1)

```
$ curl http://localhost:30062
LB Application - version :1
```

Release 2 (update) - change of label:
 
```
$ kubectl apply -f kubernetes/kube-templates/rolling-update/lbapp-v2-deployment.yml -n my-app
deployment "lbapp-deployment" configured

$ kubectl rollout history deployment/lbapp-deployment -n my-app
deployments "lbapp-deployment"
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

The application LBAPP should display the current version of the application (version 2).

```
$ curl http://localhost:30062
LB Application - version :2
```

Rollback

```
$ kubectl rollout undo deployment/lbapp-deployment --to-revision=1 -n my-app
deployment "lbapp-deployment"
```
The application LBAPP has been rollbacked to first version. Now the application should display version 1 as the current version.

```
$ curl http://localhost:30062
LB Application - version :1
```


Step 10 of 13 - Load balancing
----------------------------------

Check endpoints:

```
$ kubectl describe svc busmeme-service -n my-app
Name:                     busmeme-service
Namespace:                my-app
Labels:                   name=web
Annotations:              <none>
Selector:                 name=web
Type:                     NodePort
IP:                       10.102.226.221
LoadBalancer Ingress:     localhost
Port:                     <unset>  3000/TCP
TargetPort:               3000/TCP
NodePort:                 <unset>  30061/TCP
Endpoints:                10.1.0.28:3000
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

The presence of the attributes `replicas: 2` in the template `lbapp-v1-deployment.yml` ensures that the cluster always run 2 identical PODS containing our application.

The endpoints shown above are the internal IP inside the cluster for each replica.

Run the following command to delete one of the POD:

```
$ kubectl delete pod [POD-NAME]
```

While this pod is terminating, an other one is spawning, Kubernetes being responsible to maintain the desired state of the cluster.

The POD selection is controlled / load-balanced by Kubernetes depending on the type of POD configured.

The application LBAPP should display randomly these endpoints, which demonstrate that our 2 PODs are in use.



Step 11 of 13 - Secrets
---------------------------

```
$ kubectl create secret generic lbapp-db --from-literal='lbapp-dbuser=produser' -n my-app --from-literal='lbapp-dbpwd=twkubernetes'
secret "lbapp-db" created

$ kubectl get secrets -n my-app 
NAME                  TYPE                                  DATA      AGE
default-token-2h5rd   kubernetes.io/service-account-token   3         2h
lbapp-db              Opaque                                2         1m
```

To demonstrate that the secrets have been transmitted to the POD, restart the POD ...

```
$ kubectl replace --force -f ./kubernetes/kube-templates/secrets/lb-app.yml -n my-app 
service "lbapp-service" configured
Warning: kubectl apply should be used on resource created by either kubectl create --save-config or kubectl apply
replicationcontroller "lbapp-rc" configured
```

The application LBAPP should display the secrets in plain text.

```
$ curl http://localhost:30062
LB Application - version :undefined
-- Secret found!' username: produser; password: twkubernetes%
```

Step 12 of 13 - Self-healing
--------------------------------

```
$ kubectl apply -f ./kubernetes/kube-templates/self-healing/lb-app-probe.yml -n my-app
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

File `/tmp/lbapp.lock` is intentionally missing. As a result, the pod is flagged as unhealthy and after a certain amount of retries, its status goes from `Running` to `CrashLoopBackOff`

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




Step 13 of 13 - Add-ons
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

