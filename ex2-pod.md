# Create a POD

## 1. Declarative configuration / POD definition

TODO 

    * Basic of the YAML format / relation with Kubectl 
    * A POD is a set of container, smallest unit of work in Kubernetes, one of the types/kind of object ... (show kind attribute in a template ..)

See kubectl info CLI

* http://kubernetes.io/docs/user-guide/configuring-containers/#configuration-in-kubernetes
* http://kubernetes.io/docs/user-guide/walkthrough/#kubectl-cli

## 2. One container 

Start 1 container in 1 POD

TODO: Nginx example

## 3. Multi-containers

Start N containers in 1 POD

TODO: Example with shop-app/catalog/review

See current example with Busmeme:

```
kubectl delete pod busmeme
kubectl -s http://localhost:8080 create -f busmeme-pod.yml --validate=false
kubectl describe pod busmeme
```