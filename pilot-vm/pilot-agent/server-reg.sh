
export CONSUL=127.0.0.1

curl -v --request PUT --data @server-demo-v1.json http://$CONSUL:8500/v1/agent/service/register
