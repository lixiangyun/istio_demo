unset http_proxy
unset HTTP_PROXY

unset https_proxy
unset HTTPS_PROXY

./envoy -c ./envoy-client-122.json --restart-epoch 0 --drain-time-s 2 --parent-shutdown-time-s 3 --service-cluster client-v1 --service-node sid