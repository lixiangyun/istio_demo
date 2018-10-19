
CONTAINER_ID=$(docker ps | grep consul_etcd_1 | awk  '{print $1}' )
docker cp $CONTAINER_ID:/usr/local/bin/etcd ./etcd/

CONTAINER_ID=$(docker ps | grep consul_pilot_1 | awk  '{print $1}' )
docker cp $CONTAINER_ID:/usr/local/bin/pilot-discovery ./

CONTAINER_ID=$(docker ps | grep consul_consul_1 | awk  '{print $1}' )
docker cp $CONTAINER_ID:/bin/consul ./consul/

CONTAINER_ID=$(docker ps | grep consul_istio-apiserver_1 | awk  '{print $1}' )
docker cp $CONTAINER_ID:/usr/local/bin/kube-apiserver ./kube-apiserver/

CONTAINER_ID=$(docker ps | grep consul_productpage-v1-sidecar_1 | awk  '{print $1}' )
docker cp $CONTAINER_ID:/usr/local/bin/pilot-agent ./pilot-agent/
docker cp $CONTAINER_ID:/usr/local/bin/envoy ./pilot-agent/

