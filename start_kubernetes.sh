#!/bin/bash


docker stop $(docker ps -a -q)
docker rm -f $(docker ps -a -q)

KUBERNETES_PORT=8080
KUBERNETES_HOST=localhost
K8S_VERSION=${K8S_VERSION:-"1.2.2"}
ETCD_VERSION=${ETCD_VERSION:-"2.2.5"}
FLANNEL_VERSION=${FLANNEL_VERSION:-"0.5.5"}
FLANNEL_IPMASQ=${FLANNEL_IPMASQ:-"true"}
FLANNEL_IFACE=${FLANNEL_IFACE:-"eth0"}
ARCH=${ARCH:-"amd64"}

MASTER_IP=192.168.99.105
#docker run -d --net=host gcr.io/google_containers/etcd:2.2.5   /usr/local/bin/etcd \
#   --addr=127.0.0.1:4001 \
#   --bind-addr=0.0.0.0:4001 \
#   --data-dir=/var/etcd/data


docker run -d --net=host gcr.io/google_containers/etcd:2.2.5   /usr/local/bin/etcd \
    --restart=on-failure \
    --net=host \
    -d \
    gcr.io/google_containers/etcd:${ETCD_VERSION} \
    /usr/local/bin/etcd \
        --listen-client-urls=http://127.0.0.1:4001,http://${MASTER_IP}:4001 \
        --advertise-client-urls=http://${MASTER_IP}:4001 \
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
   --privileged=true   gcr.io/google_containers/hyperkube:v1.2.4 \
   /hyperkube kubelet \
   --containerized \
   --hostname-override="127.0.0.1" \
   --address="0.0.0.0" \
   --api-servers=http://$KUBERNETES_HOST:$KUBERNETES_PORT \
   --config=/etc/kubernetes/manifests
run_status=$?
[[ ${run_status} != 0 ]] && printf $RED "Error: Failed to start Kubernetes Kubelet" && echo && exit ${run_status}

docker run -d --net=host --privileged gcr.io/google_containers/hyperkube:v1.2.4   /hyperkube proxy \
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

#kubectl create -f ns-kube-system.yml
#kubectl get namespaces

#http://kubernetes.io/docs/user-guide/ui-access/
#http://kubernetes.io/docs/user-guide/ui/

#kubectl delete rc kubernetes-dashboard --namespace=kube-system
#kubectl delete svc kubernetes-dashboard --namespace=kube-system
#kubectl create -f kubernetes-dashboard.yaml --namespace=kube-system
#kubectl delete svc kubernetes-dashboard --namespace=kube-system


kubectl create -f dashboard-controller.yaml --namespace=kube-system
kubectl create -f dashboard-service.yaml --namespace=kube-system

#
#kubernetes-dashboard-v1.1.0-beta2
#
#kubectl -s http://localhost:8080 create -f kube-ui-rc.yaml
#kubectl -s http://localhost:8080 create -f kube-ui-svc.yaml
#