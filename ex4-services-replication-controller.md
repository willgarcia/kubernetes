# Load balancing

kubectl create -f busmeme-service.yml
kubectl create -f busmeme-rc.yml

Check endpoints:

```
root@workshop:/home/vagrant# kubectl describe svc busmeme-service
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


# Health check


kubectl create -f lb-app-probe.yml


Check the status of one of the pods

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


Health check is configure to verify the presence of this file inside the container: /tmp/lbapp.lock


Add the following lines to ....


livenessProbe:
     exec:
       command:
         - cat
         - /tmp/lbapp.lock
     initialDelaySeconds: 15
     timeoutSeconds: 1
   name: liveness


File is missing, as a result the pod is flagged as unhealthy and after a certain amount of retries, its status goes from Running to CrashLoopBackOff


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


http://kubernetes.io/docs/user-guide/production-pods/#liveness-and-readiness-probes-aka-health-checks


# Resource management

http://kubernetes.io/docs/user-guide/production-pods/#resource-management


# Secrets


 kubectl create secret generic lbapp-db --from-literal='lbapp-dbuser=produser' --from-literal='lbapp-dbpwd=twkubernetes'
 kubectl get secrets




https://github.com/kubernetes/kubernetes/blob/release-1.3/docs/design/secrets.md