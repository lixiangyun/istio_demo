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

