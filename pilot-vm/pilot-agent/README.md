## 添加envoy运行的 uid 和 app 运行的uid

```
mkdir /var/lib/istio
useradd -m --uid 1337 istio-proxy &&  echo "istio-proxy ALL=NOPASSWD: ALL" >> /etc/sudoers && chown -R istio-proxy /var/lib/istio
useradd -m --uid 1338 istio-proxy-app &&  echo "istio-proxy-app ALL=NOPASSWD: ALL" >> /etc/sudoers
```

## 指定 1338 uid 重定向到 15001 envoy代理端口
```
iptables -t nat -A OUTPUT -m owner --uid-owner 1338 -p tcp -j REDIRECT --to-ports 15001
```

## 添加IP与域名对应关系
```
echo "127.0.0.1       server.service.consul" >> /etc/hosts
echo "127.0.0.1       client.service.consul" >> /etc/hosts
```

## 启动client
```
su istio-proxy-app -c "./client -addr server.service.consul:8001 -limit 1 -debug -par 1"
```

## old iptables 规则，仅供参考

```
*nat
:PREROUTING ACCEPT [2:496]
:INPUT ACCEPT [2:496]
:OUTPUT ACCEPT [243:16879]
:POSTROUTING ACCEPT [446:27975]
:DOCKER_OUTPUT - [0:0]
:DOCKER_POSTROUTING - [0:0]
:ISTIO_OUTPUT - [0:0]
:ISTIO_REDIRECT - [0:0]
-A PREROUTING -m comment --comment "istio/install-istio-prerouting" -j ISTIO_REDIRECT
-A OUTPUT -d 127.0.0.11/32 -j DOCKER_OUTPUT
-A OUTPUT -p tcp -m comment --comment "istio/install-istio-output" -j ISTIO_OUTPUT
-A POSTROUTING -d 127.0.0.11/32 -j DOCKER_POSTROUTING
-A DOCKER_OUTPUT -d 127.0.0.11/32 -p tcp -m tcp --dport 53 -j DNAT --to-destination 127.0.0.11:45413
-A DOCKER_OUTPUT -d 127.0.0.11/32 -p udp -m udp --dport 53 -j DNAT --to-destination 127.0.0.11:43223
-A DOCKER_POSTROUTING -s 127.0.0.11/32 -p tcp -m tcp --sport 45413 -j SNAT --to-source :53
-A DOCKER_POSTROUTING -s 127.0.0.11/32 -p udp -m udp --sport 43223 -j SNAT --to-source :53
-A ISTIO_OUTPUT ! -d 127.0.0.1/32 -o lo -m comment --comment "istio/redirect-implicit-loopback" -j ISTIO_REDIRECT
-A ISTIO_OUTPUT -m owner --uid-owner 1337 -m comment --comment "istio/bypass-envoy" -j RETURN
-A ISTIO_OUTPUT -d 127.0.0.1/32 -m comment --comment "istio/bypass-explicit-loopback" -j RETURN
-A ISTIO_OUTPUT -m comment --comment "istio/redirect-default-outbound" -j ISTIO_REDIRECT
-A ISTIO_REDIRECT -p tcp -m comment --comment "istio/redirect-to-envoy-port" -j REDIRECT --to-ports 15001
```

