#!/bin/bash

export KONG_PROXY_LISTEN=0.0.0.0:8080
#export KONG_ADMIN_LISTEN=0.0.0.0:8080

export LD_LIBRARY_PATH=/home/vcap/deps/0/apt/usr/local/lib:/home/vcap/deps/0/apt/usr/local/lib/lua/5.1/:/home/vcap/deps/0/apt/usr/local/openresty/luajit/lib:/home/vcap/deps/0/apt/usr/local/openresty/pcre/lib:/home/vcap/deps/0/apt/usr/local/openresty/openssl111/lib:$LD_LIBRARY_PATH
export LUA_PATH='/home/vcap/deps/0/apt/usr/local/share/lua/5.1/?.lua;/home/vcap/deps/0/apt/usr/local/share/lua/5.1/?/init.lua;/home/vcap/deps/0/apt/usr/local/openresty/lualib/?.lua'
export LUA_CPATH='/home/vcap/deps/0/apt/usr/local/lib/lua/5.1/?.so'
export PATH=/home/vcap/deps/0/apt/usr/local/bin/:/home/vcap/deps/0/apt/usr/local/openresty/nginx/sbin:/home/vcap/deps/0/apt/usr/local/openresty/bin:$PATH

grep -irIl '/usr/local' ../deps/0/apt | xargs sed -i -e 's|/usr/local|/home/vcap/deps/0/apt/usr/local|'

SERVICE=aws-rds
export KONG_PG_USER=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.username'`
export KONG_PG_HOST=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.host'`
export KONG_PG_PORT=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.port'`
export KONG_PG_DATABASE=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.db_name'`
export KONG_PG_PASSWORD=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.password'`
export KONG_LUA_PACKAGE_PATH=$LUA_PATH
export KONG_LUA_PACKAGE_CPATH=$LUA_CPATH

# start kong
kong migrations bootstrap
kong start --vv

# keep this process alive
while true;do
	sleep 10
	nginx_count=`ps aux | grep maste[r] | wc -l`
	if [ "$nginx_count" != "1" ];then
		echo "Some process crashed"
		ps aux
		exit 1
	fi
done
