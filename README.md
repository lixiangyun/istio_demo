# istio部署

环境准备: 一台linux vm，安装好 dockerd 和 docker-compose
还需要配置docker的http_proxy，需要下载镜像。

- ubuntu linux

    ```
    apt update
    apt install -y docker.io docker-compose
    ```

- suse linux

    ```
    zypper ref
    zypper in -y docker docker-compose
    ```

- 启动docker服务

    ```
    service docker start
    ```

## 官方默认的[bookinfo](https://istio.io/docs/examples/bookinfo/)示例

![](./bookinfo/bookinfo.svg)

- 1.启动操作如下：

    ```
    cd istio_vm
    docker-compose -f consul/istio.yaml up -d
    docker-compose -f bookinfo/bookinfo.yaml up -d
    docker-compose -f bookinfo/bookinfo.sidecars.yaml up -d
    ```

- 2.如果发现pilot容器状态退出，重新执行一下:

    ```
    docker-compose -f consul/istio.yaml up -d
    ```

    注：怀疑是容器间相互依赖，同时启动时，存在并发导致的失败问题。

- 3.清理操作如下:

    ```
    docker-compose -f bookinfo/bookinfo.sidecars.yaml down
    docker-compose -f bookinfo/bookinfo.yaml down
    docker-compose -f consul/istio.yaml down
    ```

- 4.查看服务状态:

    ```
    docker ps -a
    ```

    通过游览器打开(IP地址为实际部署的VM地址)

    ```
    http://10.100.100.191:9081/productpage?u=normal
    ```

    反复刷新该地址，会发现Reviewer的五角星颜色变化（红、黑）此时服务启动正常。

## 调试工具容器使用

查看容器状态，发现启动了和服务相同的容器（ubuntu-tools），这些容器是为了方便调试而外启动的，可以查看（[bookinfo/bookinfo.sidecars.yaml](bookinfo/bookinfo.sidecars.yaml)）。

```
root@HSH1000071152:~# docker ps -a | grep tools                          
868940532e91        linimbus/ubuntu-tools:latest      "/root/hold_on.sh"   6 days ago     Up 6 days    bookinfo_standalone-ubuntu_1
349e0b2eb732        linimbus/ubuntu-tools:latest      "/root/hold_on.sh"   6 days ago     Up 6 days    bookinfo_ratings-v1-ubuntu_1
1f291704d218        linimbus/ubuntu-tools:latest      "/root/hold_on.sh"   7 days ago     Up 7 days    bookinfo_reviews-v1-ubuntu_1
69f3b20232e0        linimbus/ubuntu-tools:latest      "/root/hold_on.sh"   7 days ago     Up 7 days    bookinfo_reviews-v3-ubuntu_1
6f681ba44460        linimbus/ubuntu-tools:latest      "/root/hold_on.sh"   7 days ago     Up 7 days    bookinfo_productpage-v1-ubuntu_1
d66942eb2a25        linimbus/ubuntu-tools:latest      "/root/hold_on.sh"   7 days ago     Up 7 days    bookinfo_reviews-v2-ubuntu_1
```

选择其中一个容器，例如“6f681ba44460”，并且执行如下操作：
```
docker exec -it 6f681ba44460 /bin/bash
```

进入容器之后，可以输入 ifconfig、iptables-save、nslookup等等命令：

例如：iptables-save 

例如：nslookup reviews.service.consul

相关的分析见[istio network](network.md)


## 虚拟机部署istio

 - **环境准备**：3个linux环境，并且安装golang编译器。

 - **二进制提取**：在前面istio容器启动的环境中，执行脚本

    ```
    cd pilot-vm
    ./download-binary.sh
    ```

    注：download-binary.sh脚本将从上面部署的容器中提取相应的二进制文件，即： etcd、consul、kube-apiserver、pilot-discovery、pilot-agent、envoy。

    执行完成之后查看一下二进制是否存在。

    注：如果不存在需要调整 download-binary.sh 脚本，或者参考该脚本手动提取。

 - **部署**：

    假设:三台linux地址如下:

    ```
    VM1:8.1.236.121
    VM2:8.1.236.122
    VM3:8.1.236.123
    ```
    
    控制面使用VM3，用于启动etcd、consul、kube-apiserver、pilot-discovery 四个控制面服务。
    服务间依赖关系为：

        - kube-apiserver 依赖 etcd 做为配置存储
        - pilot-discovery 依赖 consul 做为服务发现
        - pilot-discovery 依赖 kube-apiserver 做为配置服务，可以使用 kubectl 下发配置。

    数据面使用VM1、VM2。用于启动app和envoy代理服务。打包拷贝pilot-vm目录至3个VM。

 - **启动控制面**：

    ```
    cd pilot-vm
    ./start-ctl.sh
    ```

    然后ps查看进程是否正常运行，nohup方式启动服务，所以退出shell，不影响服务运行。
    
    注：如果IP不一样，需要替换相应的IP地址，参考如下：

    ```
    ./consul/config/agent.json
    ./consul/config/server.json
    ./consul/consul.sh
    ./etcd/etcd.sh
    ./kube-apiserver/kube-apiserver.sh
    ./pilot-discovery/kubeconfig
    ./pilot-discovery/pilot-discovery.sh
    ```

- **启动服务端**：

    编译server服务，参考[测试工具](testtools.md)。copy放至server目录下。

    在VM1启动服务:
    ```
    cd pilot-vm/pilot-agent
    ./server-start.sh
    ```

    查看该脚本，完成了三个操作：

        - 1.启动http server服务
        - 2.通过curl工具向consul注册服务
        - 3.启动envoy代理进程

    通过ps查看envoy和server进行是否存在，不存在需要查看相应日志。

    ```
    ./server/output.txt
    ./envoy-output.log
    ```

    注：如果IP需要修改，请修改一下文件：

    ```
    ./server-start.sh         # VM3地址
    ./envoy-server-121.json   # VM1和VM3地址
    ./consul-server-121.json  # VM1地址
    ```

- **启动客户端**：

    编译client服务，参考[测试工具](testtools.md)。copy放至server目录下。分四个步骤：

    - 1.创建istio-proxy-app用户，用于app运行。（单VM执行一次即可）

        ```
        useradd -m --uid 1338 istio-proxy-app &&  echo "istio-proxy-app ALL=NOPASSWD: ALL" >> /etc/sudoers
        ```

    - 2.指定 1338 uid 重定向到 15001 envoy代理端口（每VM重启需要执行一次）
  
        ```
        iptables -t nat -A OUTPUT -m owner --uid-owner 1338 -p tcp -j REDIRECT --to-ports 15001
        ```

    - 3.注入域名（单VM执行一次即可）
  
        ```
        echo "127.0.0.1 server.service.consul" >> /etc/hosts 
        ```

    - 4.启动client测试

        ```
        chmod 777 -R *
        cd client
        su istio-proxy-app -c "./client -addr server.service.consul:8001 -par 1 -limit 1 -debug"
        ```

        如果IP需要修改，请修改一下文件：

        ```
        ./client-start.sh         # VM3地址
        ./envoy-client-122.json   # VM2和VM3地址
        ./consul-client-122.json  # VM2地址
        ```

- **原理说明**：

    - 二进制提取

        istio基于vm的部署，是参考容器的部署方式，参考容器的启动和部署方式，提前二进制和编写启动脚本，VM3的四个服务的启动方式，是参考`docker-compose -f consul/istio.yaml up -d` ，可以打开看下consul/istio.yaml，可以得知容器的启动参数。然后结合容器的Dockerfile文件（[istio官方github仓库](https://github.com/istio/istio)）。提取相应的二进制文件。

    - 启动脚本
      
        App的启动，参考`docker-compose -f bookinfo/bookinfo.yaml up -d`和`docker-compose -f bookinfo/bookinfo.sidecars.yaml up -d`，其中参考了sidecars的启动方式（proxy_init和proxy_debug）。其中proxy_init 主要是执行istio-iptables.sh，完成iptables规则下发。在前面的容器调试章节，可以看到下发的规则内容。

        也可以通过`docker inspect`命令，导出容器相关的启动信息；
        
        例如：
        ```
        docker ps -a | grep proxy_init
        ```
        
        选择一个容器ID
        
        ```
        docker inspect f211dea18128
        ```
        
        可以看到相关的启动脚本和参数。
        
        ```
        ...
            "Args": [
                "-p",
                "15001",
                "-u",
                "1337"
            ],
        ...
        ```
        
        分析之后，其实可以得知proxy_init主要完成了ingress、outgress流量的引流规则。
        在VM部署的情况下，我们简化了outgress规则为；
        
        ```
        iptables -t nat -A OUTPUT -m owner --uid-owner 1338 -p tcp -j REDIRECT --to-ports 15001
        ```
        
        基本思想为，设定app运行uid，并且指定nat表，output链中，针对该uid的app，所有tcp流量重定向到 15001端口，该端口其实就是envoy监听的端口，这个可以通过在调试容器中`netstat -nap`或者`iptables-save`规则中得知。通过uid隔离了VM其他App的OUTPUT规则，避免影响其他app正常运行。
        
        目前ingress的引流配置还没有做，原理应该类似，参考如下：
        
        ```
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 8001 -j REDIRECT --to-ports 15001
        ```
        为了避免对VM的其他app产生影响，只针对向8001端口的发起请求进行截获。
        
        
