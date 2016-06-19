#!/usr/bin/env bash

export MASTER_IP=192.168.33.10
export K8S_VERSION=1.2.1
export ETCD_VERSION=2.2.1
export FLANNEL_VERSION=0.5.5
export FLANNEL_IFACE=eth0
export FLANNEL_IPMASQ=true

readonly CONTAINER_NAME_PREFIX="kubernetes-"
readonly KUBERNETES_HOSTNAME="unix:///var/run/docker-bootstrap.sock"

docker daemon\
    -H ${KUBERNETES_HOSTNAME}\
    -p /var/run/docker-bootstrap.pid\
    --iptables=false\
    --ip-masq=false\
    --bridge=none\
    --graph=/var/lib/docker-bootstrap 2> /var/log/docker-bootstrap.log 1> /dev/null &

#service docker stop

FLANNEL_CONTAINER_ID=$(
    docker -H ${KUBERNETES_HOSTNAME}\
        run\
            --name=${CONTAINER_NAME_PREFIX}flannel\
            --detach\
            --net=host\
            --privileged\
            -v /dev/net:/dev/net\
            quay.io/coreos/flannel:${FLANNEL_VERSION} /opt/bin/flanneld\
                --ip-masq=${FLANNEL_IPMASQ}\
                --etcd-endpoints=http://${MASTER_IP}:4001\
                --iface=${FLANNEL_IFACE}
)

docker -H ${KUBERNETES_HOSTNAME}\
    exec\
        ${FLANNEL_CONTAINER_ID} cat /run/flannel/subnet.env | grep 'FLANNEL_SUBNET\|FLANNEL_MTU' > /etc/default/docker
echo "DOCKER_OPTS=\"--bip=\${FLANNEL_SUBNET} --mtu=\${FLANNEL_MTU}\"" >> /etc/default/docker

service docker start

docker run\
     --name=${CONTAINER_NAME_PREFIX}kubelet\
     --volume=/:/rootfs:ro\
     --volume=/sys:/sys:ro\
     --volume=/dev:/dev\
     --volume=/var/lib/docker/:/var/lib/docker:rw\
     --volume=/var/lib/kubelet/:/var/lib/kubelet:rw\
     --volume=/var/run:/var/run:rw\
     --net=host\
     --privileged=true\
     --pid=host\
     --detach\
     gcr.io/google_containers/hyperkube-amd64:v${K8S_VERSION}\
         /hyperkube kubelet\
         --allow-privileged=true\
         --api-servers=http://${MASTER_IP}:8080\
         --v=2\
         --address=0.0.0.0\
         --enable-server\
         --containerized

docker run\
    --name=${CONTAINER_NAME_PREFIX}proxy\
    --detach\
    --net=host\
    --privileged\
    gcr.io/google_containers/hyperkube-amd64:v${K8S_VERSION}     /hyperkube proxy\
        --master=http://${MASTER_IP}:8080\
        --v=2
