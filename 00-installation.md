# Installation

## pre-requisites
* Docker(-machine).
* Kubernetes client (`brew install kubectl`) - For mac users

For the workshop, we will use the 2 workshops VMs instead of a Docker machine.

## installation

```
# vm creation
DOCKER_MACHINE_NAME=kubetest
docker-machine rm -f $DOCKER_MACHINE_NAME
docker-machine create --driver virtualbox  --virtualbox-memory 4096 $DOCKER_MACHINE_NAME
eval "$(docker-machine env kubetest)"
docker-machine ssh $DOCKER_MACHINE_NAME -f -N -L "8080:localhost:8080"
```
