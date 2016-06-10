#!/bin/bash


docker stop $(docker ps -a -q)
docker rm -f $(docker ps -a -q)

readonly KUBERNETES_PORT="8080"
readonly KUBERNETES_HOST="localhost"

docker run -d --net=host gcr.io/google_containers/etcd:2.0.12   /usr/local/bin/etcd \
   --addr=127.0.0.1:4001 \
   --bind-addr=0.0.0.0:4001 \
   --data-dir=/var/etcd/data
run_status=$?
[[ ${run_status} != 0 ]] && printf $RED "Error: Failed to start etcd" && echo && exit ${run_status}

docker run -d \
   --volume=/:/rootfs:ro \
   --volume=/sys:/sys:ro \
   --volume=/dev:/dev \
   --volume=/var/lib/docker/:/var/lib/docker:ro \
   --volume=/var/lib/kubelet/:/var/lib/kubelet:rw \
   --volume=/var/run:/var/run:rw \
   --net=host \
   --pid=host \
   --privileged=true   gcr.io/google_containers/hyperkube:v1.0.1     /hyperkube kubelet \
   --containerized \
   --hostname-override="127.0.0.1" \
   --address="0.0.0.0" \
   --api-servers=http://$KUBERNETES_HOST:$KUBERNETES_PORT \
   --config=/etc/kubernetes/manifests
run_status=$?
[[ ${run_status} != 0 ]] && printf $RED "Error: Failed to start Kubernetes Kubelet" && echo && exit ${run_status}

docker run -d --net=host --privileged gcr.io/google_containers/hyperkube:v1.0.1   /hyperkube proxy \
   --master=http://127.0.0.1:$KUBERNETES_PORT \
   --v=2
run_status=$?
[[ ${run_status} != 0 ]] && printf $RED "Error: Failed to start Kubernetes Proxy" && echo && exit ${run_status}

until $(kubectl -s http://$KUBERNETES_HOST:$KUBERNETES_PORT cluster-info &> /dev/null); do
    echo "Waiting for cluster startup..."
    sleep 1
done

run_status=$?
[[ ${run_status} == 0 ]] && printf $GREEN "Kubernetes started" && echo
