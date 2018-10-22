unset http_proxy
unset HTTP_PROXY

unset https_proxy
unset HTTPS_PROXY

export CONSUL=8.1.236.123

curl -v --request PUT --data @consul-client-122.json http://$CONSUL:8500/v1/agent/service/register

nohup ./envoy -c ./envoy-client-122.json --restart-epoch 0 --drain-time-s 2 --parent-shutdown-time-s 3 --service-cluster server-v1 --service-node sid 1>envoy-output.log 2>1& &

