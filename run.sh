#!/bin/bash

export KONG_PROXY_LISTEN=0.0.0.0:8080
#export KONG_ADMIN_LISTEN=0.0.0.0:8080
export LD_LIBRARY_PATH=/home/vcap/app/.apt/usr/local/lib:/home/vcap/app/.apt/usr/local/lib/lua/5.1/:$LD_LIBRARY_PATH
export LUA_PATH='/home/vcap/app/.apt/usr/local/share/lua/5.1/?.lua;/home/vcap/app/.apt/usr/local/share/lua/5.1/?/init.lua;/home/vcap/app/.apt/usr/local/openresty/lualib/?.lua'
export LUA_CPATH='/home/vcap/app/.apt/usr/local/lib/lua/5.1/?.so'
export PATH=/home/vcap/app/.apt/usr/local/bin/:$PATH

# hack ;)
#grep -irIl '/usr/local' ./apt | xargs sed -i -e 's|/usr/local|/home/vcap/app/.apt/usr/local|'

# configure postgres
SERVICE=aws-rds
export KONG_PG_USER=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.username'`
export KONG_PG_HOST=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.host'`
export KONG_PG_PORT=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.port'`
export KONG_PG_DATABASE=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.db_name'`
export KONG_PG_PASSWORD=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.password'`
export KONG_LUA_PACKAGE_PATH=$LUA_PATH
export KONG_LUA_PACKAGE_CPATH=$LUA_CPATH

lsb_release -sc

# start kong
kong start --vv

# keep this process alive
while true;do
	sleep 3
	nginx_count=`ps aux | grep maste[r] | wc -l`
	if [ "$nginx_count" != "1" ];then
		echo "Some process crashed"
		ps aux
		exit 1
	fi
done

