unset http_proxy
unset HTTP_PROXY

unset https_proxy
unset HTTPS_PROXY

nohup ./kube-apiserver --etcd-servers http://8.1.236.123:2379 --service-cluster-ip-range 10.99.0.0/16 --insecure-port 8080 -v 2 --insecure-bind-address 0.0.0.0 1>output.log 2>&1 &