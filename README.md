# istio_demo

## install

```
docker-compose -f consul/istio.yaml up -d
docker-compose -f bookinfo/bookinfo.yaml up -d
docker-compose -f bookinfo/bookinfo.sidecars.yaml up -d
```

## debug

```
docker ps -a
docker exec {ubuntu-tools-container-id} /bin/bash
iptables-save
```

## download binary
./download-binary.sh

## add uid 和 gid
groupadd --gid 1337 istio_proxy
useradd -u 1337 -g istio_proxy -m istio_proxy

# 添加envoy运行的 uid 和 app 运行的uid
mkdir /var/lib/istio
useradd -m --uid 1337 istio-proxy &&  echo "istio-proxy ALL=NOPASSWD: ALL" >> /etc/sudoers && chown -R istio-proxy /var/lib/istio
useradd -m --uid 1338 istio-proxy-app &&  echo "istio-proxy-app ALL=NOPASSWD: ALL" >> /etc/sudoers

# 指定 1338 uid 重定向到 15001 envoy代理端口
iptables -t nat -A OUTPUT -m owner --uid-owner 1338 -p tcp -j REDIRECT --to-ports 15001

# 分别在服务端、客户端节点启动
./server-start.sh
./client-start.sh 

# 客户端启动测试app
su istio-proxy-app -c "./client -addr server.service.consul:8001 -par 1 -limit 1 -debug"

