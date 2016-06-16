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
