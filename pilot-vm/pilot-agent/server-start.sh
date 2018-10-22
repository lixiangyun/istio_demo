
unset http_proxy
unset HTTP_PROXY

unset https_proxy
unset HTTPS_PROXY

cd server
rm -rf *.log
go build .
./server -name server -ver 1.0 -p :8001 1>output.txt 2>&1 &
cd ..
sleep 3

export CONSUL=8.1.236.123

curl  --request PUT --data @consul-server-121.json http://$CONSUL:8500/v1/agent/service/register

nohup ./envoy -c ./envoy-server-121.json --restart-epoch 0 --drain-time-s 2 --parent-shutdown-time-s 3 --service-cluster server-v1 --service-node sid 1>envoy-output.log 2>&1 &

