#!/usr/bin/env bash

export MASTER_IP=192.168.33.10
export K8S_VERSION=1.2.1
export ETCD_VERSION=2.2.1
export FLANNEL_VERSION=0.5.5
export FLANNEL_IFACE=eth0
export FLANNEL_IPMASQ=true

sudo sh -c 'docker daemon -H unix:///var/run/docker-bootstrap.sock -p /var/run/docker-bootstrap.pid --iptables=false --ip-masq=false --bridge=none --graph=/var/lib/docker-bootstrap 2> /var/log/docker-bootstrap.log 1> /dev/null &'
docker -H unix:///var/run/docker-bootstrap.sock run -d     --net=host     gcr.io/google_containers/etcd-amd64:${ETCD_VERSION}     /usr/local/bin/etcd         --listen-client-urls=http://127.0.0.1:4001,http://${MASTER_IP}:4001         --advertise-client-urls=http://${MASTER_IP}:4001         --data-dir=/var/etcd/data
docker -H unix:///var/run/docker-bootstrap.sock run     --net=host     gcr.io/google_containers/etcd-amd64:${ETCD_VERSION}     etcdctl set /coreos.com/network/config '{ "Network": "10.1.0.0/16" }'
service docker stop
docker -H unix:///var/run/docker-bootstrap.sock run -d     --net=host     --privileged     -v /dev/net:/dev/net     quay.io/coreos/flannel:${FLANNEL_VERSION}     /opt/bin/flanneld         --ip-masq=${FLANNEL_IPMASQ}         --iface=${FLANNEL_IFACE}
docker -H unix:///var/run/docker-bootstrap.sock exec e34c0cff30822a605c9c3a6555dc8426161af5c5a134293d475b072205b36b16 cat /run/flannel/subnet.env
sudo /sbin/ifconfig docker0 down
sudo brctl delbr docker0
sudo /etc/init.d/docker start
service docker start
docker run --volume=/:/rootfs:ro     --volume=/sys:/sys:ro     --volume=/var/lib/docker/:/var/lib/docker:rw     --volume=/var/lib/kubelet/:/var/lib/kubelet:rw     --volume=/var/run:/var/run:rw     --net=host     --privileged=true     --pid=host     -d     gcr.io/google_containers/hyperkube-amd64:v${K8S_VERSION}     /hyperkube kubelet         --allow-privileged=true         --api-servers=http://localhost:8080         --v=2         --address=0.0.0.0         --enable-server         --hostname-override=127.0.0.1         --config=/etc/kubernetes/manifests-multi         --containerized         --cluster-dns=10.0.0.10         --cluster-domain=cluster.local
wget http://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubectl
chmod 755 kubectl
mv kubectl /usr/bin/local/
