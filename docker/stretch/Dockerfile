FROM nginx:${NGINX_VERSION} AS build

RUN apt-get update \
    && apt-get install -y \
        curl \
        gcc \
        libcurl4-openssl-dev \
        libgd-dev \
        libgeoip-dev \
        libjansson-dev \
        libpcre3-dev \
        libssl-dev \
        libxslt-dev \
        make \
        openssl \
        zlib1g-dev

RUN mkdir -p /opt/nginx/nginx_auth_accessfabric
WORKDIR /opt/nginx
COPY /config /opt/nginx/nginx_auth_accessfabric/
COPY /ngx_http_auth_accessfabric_module.c /opt/nginx/nginx_auth_accessfabric/

RUN curl -SsL -o "libxjwt-${LIBXJWT_VERSION}.tar.gz" "https://github.com/ScaleFT/libxjwt/releases/download/v${LIBXJWT_VERSION}/libxjwt-${LIBXJWT_VERSION}.tar.gz" \
    && tar -xzf "libxjwt-${LIBXJWT_VERSION}.tar.gz" \
    && cd "libxjwt-${LIBXJWT_VERSION}" \
    && ./configure \
    && make \
    && make install

# config required for binary compatability
# copy from https://github.com/nginxinc/docker-nginx/blob/master/stable/alpine/Dockerfile
RUN CONFIG="\
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=nginx \
		--group=nginx \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-http_xslt_module=dynamic \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module=dynamic \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-stream_realip_module \
		--with-stream_geoip_module=dynamic \
		--with-http_slice_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-compat \
		--with-file-aio \
		--with-http_v2_module \
	" \
    && curl -SsL -o "nginx-${NGINX_VERSION}.tar.gz" "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
    && tar -xzf "nginx-${NGINX_VERSION}.tar.gz" \
    && cd "nginx-${NGINX_VERSION}" \
    && ./configure $CONFIG --add-dynamic-module=../nginx_auth_accessfabric \
    && make \
    && make install

# final image - copy module from build image for reduced size
FROM nginx:${NGINX_VERSION}

RUN apt-get update \
    && apt-get install -y \
        libcurl4-openssl-dev \
        libjansson-dev \
    && sed -i '1s|^|load_module modules/ngx_http_auth_accessfabric_module.so;|' /etc/nginx/nginx.conf

COPY --from=build /usr/local/lib/libxjwt.a /usr/local/lib/libxjwt.la /usr/local/lib/libxjwt.so.0.1.0 /usr/lib/x86_64-linux-gnu/
RUN ln -s /usr/lib/x86_64-linux-gnu/libxjwt.so.0.1.0 /usr/lib/x86_64-linux-gnu/libxjwt.so.0 \
    && ln -s /usr/lib/x86_64-linux-gnu/libxjwt.so.0.1.0 /usr/lib/x86_64-linux-gnu/libxjwt.so \
    && ldconfig

COPY --from=build /opt/nginx/nginx-${NGINX_VERSION}/objs/ngx_http_auth_accessfabric_module.so /etc/nginx/modules/
