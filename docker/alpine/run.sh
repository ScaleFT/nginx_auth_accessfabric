#!/bin/bash

cd $(dirname $0)
. ../vars.env

docker run --rm -p 8080:80 "scaleft/nginx:${NGINX_VERSION}-alpine"
