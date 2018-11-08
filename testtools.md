# 性能测试工具

基于golang编写的测试http、tcp协议的性能，时延工具。

## 环境准备
linux+golang

## http client

做为http客户端程序，构造http请求报，并且循环发送至服务端。支持多协程发起请求。
支持定速发送，可以通过参数构造请求的body大小，head，url。以测试不同维度。
会校验请求的结果，默认200为成功，失败会打印错误。
并统计每个请求的平均时延，每秒的请求总数，每秒占用带宽的大小。

### build

```
cd pilot-vm/pilot-agent/client
go build .
```

### run 

```
root@ubuntu-121:~/banchmark/client# ./client --help
Usage of ./client:
  -addr string
        set the service address. (default "127.0.0.1:8001")
  -body int
        transport body length. (default 128)
  -h    this help.
  -head string
        set request head. as[key1=value1,key2=value2]
  -limit int
        limit number per second to send every goroutine. as[0,1000].
  -par int
        the parallel numbers to request. (default 10)
  -runtime int
        total run time. (default 120)
  -url string
        set request url. as[/abc/123] (default "/")
```

参数说明

- **-addr** 请求的服务端地址
- **-body** 请求的body大小，单位bytes，默认128字节
- **-head** 头域的kv键值对，默认没有
- **-limit** 速率限制，每个协程每秒钟发送的请求数量，默认无限制（死循环发送）。
- **-par** 协程数量（即每个协程单独发起http请求链路），默认10个协程。
- **-runtime** 测试执行的时间，默认120秒。
- **-url** 请求的url路径，默认"/"

输出说明

```
2018/11/05 11:19:04 Request : http://127.0.0.1:8001/ 
2018/11/05 11:19:04 BodyLen : 128
2018/11/05 11:19:04 PARAL   : 10
2018/11/05 11:19:04 Http Benchmark Start!
2018/11/05 11:19:09 [./client] stat: [ time 192.98 us , count 48.64 k/s , size 6.08 M/s ]
2018/11/05 11:19:14 [./client] stat: [ time 198.16 us , count 47.31 k/s , size 5.91 M/s ]
2018/11/05 11:19:19 [./client] stat: [ time 199.90 us , count 46.84 k/s , size 5.86 M/s ]
...
2018/11/05 11:21:04 [./client] avg : [ time 204.97 us , count 45.68 k/s , size 5.71 M/s ] total 23
2018/11/05 11:21:04 Http Benchmark Stop!
```

输出请求的url路径，body大小，并发数，每5秒的平均统计信息。在退出时，输出之前采样的平均值。

## http server

做为http服务端，接收所有请求，并且将请求的body、head做为响应发送给客户端。支持并发请求处理。
并发数量根据请求的链路数据决定。

### build

```
cd pilot-vm/pilot-agent/server
go build .
```

### run 

```
root@ubuntu-121:~/banchmark/server# ./server -h
Usage of ./server:
  -h    this help.
  -name string
        set the service name. (default "demohttp")
  -p string
        set the service listen addr. (default "127.0.0.1:8001")
  -ver string
        set the service version. (default "1")
```

参数说明

- **-name** 服务名，打印信息使用。
- **-p** 服务端监听的地址（ip:port）。
- **-ver** version信息,打印信息使用。

输出说明

```
2018/11/05 11:20:00 [serverv1.0 :8001] stat: [ time 0 ns , count 45.49k/s , size 5.69M/s ]
2018/11/05 11:20:05 [serverv1.0 :8001] stat: [ time 0 ns , count 45.67k/s , size 5.71M/s ]
2018/11/05 11:20:10 [serverv1.0 :8001] stat: [ time 0 ns , count 45.54k/s , size 5.69M/s ]
```

打印每秒的请求数量(count xx k/s)，以及占用带宽大小( size xx M/s)。
