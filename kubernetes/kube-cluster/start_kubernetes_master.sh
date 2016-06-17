#!/usr/bin/env bash

# see http://kubernetes.io/docs/getting-started-guides/docker-multinode/#master-node

export MASTER_IP=192.168.33.10
export K8S_VERSION=1.2.1
export ETCD_VERSION=2.2.1
export FLANNEL_VERSION=0.5.5
export FLANNEL_IFACE=eth1
export FLANNEL_IPMASQ=true

####
## TODO: kubectl installation, move this code in the dockerprod-auth-env -> provisionning scripts
wget http://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubectl
chmod 755 kubectl
mv kubectl /usr/local/bin
####

####
## TODO: bridge-utils installation, move this code in the dockerprod-auth-env -> provisionning scripts
apt-get update
apt-get install bridge-utils -y
####

CONTAINER_NAME_PREFIX="kubernetes-"
KUBERNETES_HOSTNAME="unix:///var/run/docker-bootstrap.sock"

docker daemon -H ${KUBERNETES_HOSTNAME}\
    -p /var/run/docker-bootstrap.pid\
    --iptables=false\
    --ip-masq=false\
    --bridge=none\
    --graph=/var/lib/docker-bootstrap 2> /var/log/docker-bootstrap.log 1> /dev/null &

docker -H ${KUBERNETES_HOSTNAME}\
    run\
        --name=${CONTAINER_NAME_PREFIX}etcd-1\
        --detach\
        --net=host\
        gcr.io/google_containers/etcd-amd64:${ETCD_VERSION} /usr/local/bin/etcd\
             --listen-client-urls=http://127.0.0.1:4001,http://${MASTER_IP}:4001\
             --advertise-client-urls=http://${MASTER_IP}:4001\
             --data-dir=/var/etcd/data

docker\
    -H ${KUBERNETES_HOSTNAME}\
    run\
        --name=${CONTAINER_NAME_PREFIX}etcd-2\
        --net=host\
             gcr.io/google_containers/etcd-amd64:${ETCD_VERSION}\
            etcdctl set /coreos.com/network/config '{ "Network": "10.1.0.0/16" }'

service docker stop

FLANNEL_CONTAINER_ID=$(
    docker -H ${KUBERNETES_HOSTNAME} run\
    --detach\
    --net=host\
    --privileged\
    -v /dev/net:/dev/net\
        quay.io/coreos/flannel:${FLANNEL_VERSION} /opt/bin/flanneld\
            --ip-masq=${FLANNEL_IPMASQ}\
            --iface=${FLANNEL_IFACE}
)

docker -H ${KUBERNETES_HOSTNAME}\
    exec\
        ${FLANNEL_CONTAINER_ID} cat /run/flannel/subnet.env | grep 'FLANNEL_SUBNET\|FLANNEL_MTU' > /etc/default/docker
echo "DOCKER_OPTS=\"--bip=\${FLANNEL_SUBNET} --mtu=\${FLANNEL_MTU}\"" >> /etc/default/docker

sudo /sbin/ifconfig docker0 down
sudo brctl delbr docker0
service docker start

docker run\
    --volume=/:/rootfs:ro\
     --volume=/sys:/sys:ro\
     --volume=/var/lib/docker/:/var/lib/docker:rw\
     --volume=/var/lib/kubelet/:/var/lib/kubelet:rw\
     --volume=/var/run:/var/run:rw\
     --net=host\
     --privileged=true\
     --pid=host\
     --detach\
     gcr.io/google_containers/hyperkube-amd64:v${K8S_VERSION}     /hyperkube kubelet\
         --allow-privileged=true\
         --api-servers=http://localhost:8080\
         --v=2\
         --address=0.0.0.0\
         --enable-server\
         --hostname-override=127.0.0.1\
         --config=/etc/kubernetes/manifests-multi\
         --containerized
