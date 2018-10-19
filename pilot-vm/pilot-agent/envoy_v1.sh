unset http_proxy
unset HTTP_PROXY

unset https_proxy
unset HTTPS_PROXY

./envoy -c ./envoy-demo-v1.json --restart-epoch 0 --drain-time-s 2 --parent-shutdown-time-s 3 --service-cluster demo-v1 --service-node sid