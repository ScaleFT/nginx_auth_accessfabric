#!/bin/bash

cd $(dirname $0)
dockerfile="$(pwd)/Dockerfile"

set -a
. ../vars.env
set +a 

cd ../../
envsubst '${LIBXJWT_VERSION} ${NGINX_VERSION}' < "$dockerfile" \
    | docker build -t "scaleft/nginx:${NGINX_VERSION}" -f - .
