#!/bin/bash

nohup ./etcd -advertise-client-urls=http://8.1.236.123:2379 -listen-client-urls=http://8.1.236.123:2379 1>output.log 2>&1 &