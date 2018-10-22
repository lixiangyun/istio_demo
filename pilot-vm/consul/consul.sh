nohup ./consul agent -server -data-dir=$PWD/data -config-dir=$PWD/config -bootstrap -bind 8.1.236.123 -http-port=8500 1>output.log 2>&1 &
#./consul agent -dev 