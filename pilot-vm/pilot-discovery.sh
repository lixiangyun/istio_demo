unset http_proxy
unset HTTP_PROXY

unset https_proxy
unset HTTPS_PROXY

./pilot-discovery discovery --httpAddr :15007 --registries Consul --consulserverURL http://8.1.236.123:8500 --kubeconfig $PWD/kubeconfig
