unset http_proxy
unset HTTP_PROXY

unset https_proxy
unset HTTPS_PROXY

./envoy -c ./envoy-server-121.json --restart-epoch 0 --drain-time-s 2 --parent-shutdown-time-s 3 --service-cluster server-v1 --service-node sid