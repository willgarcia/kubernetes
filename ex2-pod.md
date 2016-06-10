* 1. Declarative configuration

TODO Explain the concept / relation with Kubectl 

* 2. One container 

Start 1 container in 1 POD

TODO Nginx example

* 3. Multi-containers

Start N containers in 1 POD

TOOD Example with shop-app/catalog/review

See current example with Busmeme:

```
kubectl delete pod busmeme
kubectl -s http://localhost:8080 create -f busmeme-pod.yml --validate=false
kubectl describe pod busmeme
```