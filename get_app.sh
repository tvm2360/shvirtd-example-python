#!/bin/bash
cd /opt
/usr/bin/git clone https://github.com/tvm2360/shvirtd-example-python.git
cd ./shvirtd-example-python
/usr/bin/docker pull nginx:1.21.1
/usr/bin/docker pull haproxy:2.4
/usr/bin/docker pull mysql:8
/usr/bin/docker pull python:3.9-slim
/usr/bin/docker build -t my_app:latest -f Dockerfile.python .
sed -i 's/ cr.yandex\/crpop9a9o6dh4hvgiv23\// /g' compose.yaml
/usr/bin/docker compose -f compose.yaml up -d

