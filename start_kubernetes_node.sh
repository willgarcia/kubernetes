export MASTER_IP=192.168.33.10
export K8S_VERSION=1.2.1
export ETCD_VERSION=2.2.1
export FLANNEL_VERSION=0.5.5
export FLANNEL_IFACE=eth0
export FLANNEL_IPMASQ=true

apt-get update
apt-get install bridge-utils -y

sudo sh -c 'docker daemon -H unix:///var/run/docker-bootstrap.sock -p /var/run/docker-bootstrap.pid --iptables=false --ip-masq=false --bridge=none --graph=/var/lib/docker-bootstrap 2> /var/log/docker-bootstrap.log 1> /dev/null &'
service docker stop
docker -H unix:///var/run/docker-bootstrap.sock run -d     --net=host     --privileged     -v /dev/net:/dev/net     quay.io/coreos/flannel:${FLANNEL_VERSION}     /opt/bin/flanneld         --ip-masq=${FLANNEL_IPMASQ}         --etcd-endpoints=http://${MASTER_IP}:4001         --iface=${FLANNEL_IFACE}
sudo docker -H unix:///var/run/docker-bootstrap.sock exec e080834f5ba9fe4fb7f54cad0c1372671bcb517b23d5cd4a8238d5f77f1f4629 cat /run/flannel/subnet.env
echo "DOCKER_OPTS=\"--bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}\"" > /etc/default/docker
sudo /sbin/ifconfig docker0 down
sudo brctl delbr docker0
service docker start
docker run     --volume=/:/rootfs:ro     --volume=/sys:/sys:ro     --volume=/dev:/dev     --volume=/var/lib/docker/:/var/lib/docker:rw     --volume=/var/lib/kubelet/:/var/lib/kubelet:rw     --volume=/var/run:/var/run:rw     --net=host     --privileged=true     --pid=host     -d     gcr.io/google_containers/hyperkube-amd64:v${K8S_VERSION}     /hyperkube kubelet         --allow-privileged=true         --api-servers=http://${MASTER_IP}:8080         --v=2         --address=0.0.0.0         --enable-server         --containerized         --cluster-dns=10.0.0.10         --cluster-domain=cluster.local
docker run -d     --net=host     --privileged     gcr.io/google_containers/hyperkube-amd64:v${K8S_VERSION}     /hyperkube proxy         --master=http://${MASTER_IP}:8080         --v=2