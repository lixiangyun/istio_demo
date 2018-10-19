export PATH=./:$PATH
export ISTIO_META_ISTIO_PROXY_VERSION=1.0.2
export ISTIO_META_ISTIO_PROXY_SHA=istio-proxy:99cfc3f74c414dd4fa4aa784a0f8b13e22b81893
export ISTIO_META_ISTIO_VERSION=1.0.2

cp envoy /usr/local/bin/envoy -rf

cp $PWD/istio/envoy/envoy_bootstrap_tmpl.json /var/lib/istio/envoy/envoy_bootstrap_tmpl.json -rf

./pilot-agent proxy --serviceregistry Consul --serviceCluster demo-v2 --zipkinAddress 127.0.0.1:9411 --configPath $PWD/istio

