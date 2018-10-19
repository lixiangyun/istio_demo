
export DNS_RESOLVES=consul
export DNS_PORT=8600

./consul agent -server -data-dir=$PWD/data -config-dir=$PWD/config -bootstrap -bind 8.1.236.123 -http-port=8500

#./consul agent -dev 