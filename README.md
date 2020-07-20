# [Kong](https://getkong.org/) on Cloud.gov

## How to deploy on cloud.gov

Note - this approach was [adapted from this repository](https://github.com/making/cf-kong). This is probably not a production ready way to run Kong, but should allow a way to test it out in the cloud.gov environment. The [Kong Docker image](https://hub.docker.com/_/kong) is another way to try out Kong APi Gateway.

```
cf create-service aws-rds shared-psql kong-db
cf push your-kong-app
```

You can swap out `shared-psql` for a [larger Postgres instance](https://cloud.gov/docs/services/relational-database/#plans) based on your needs. You can also adjust the amount of memory used by the app by changing the setting in the `manifest.yml` file.

port `8080` is used for incoming HTTP traffic from your clients. You can access this endpoint via `https://your-kong-app.app.cloud.gov`.

### Note - instructions below have not been verified/updated.

Port `8001` is used for the Admin API. You can access this endpoint with the following command.

```
cf ssh -N -T -L 8001:localhost:8001 your-kong
```

## Add your API

```
$ cf map-route your-kong cfapps.io -n example-api-kong
$ curl -is -X POST http://localhost:8001/apis -d name=example-api -d hosts=example-api-kong.cfapps.io -d upstream_url=http://httpbin.org 
HTTP/1.1 201 Created
Date: Wed, 05 Jul 2017 18:21:10 GMT
Content-Type: application/json; charset=utf-8
Transfer-Encoding: chunked
Connection: keep-alive
Access-Control-Allow-Origin: *
Server: kong/0.10.3

{"http_if_terminated":true,"id":"278a32ee-d9a9-48ac-92eb-7f39070545ea","retries":5,"preserve_host":false,"created_at":1499278870000,"upstream_connect_timeout":60000,"upstream_url":"http:\/\/httpbin.org","upstream_read_timeout":60000,"https_only":false,"upstream_send_timeout":60000,"strip_uri":true,"name":"example-api","hosts":["example-api-kong.cfapps.io"]}
```

## Forward your requests through Kong

```
curl https://example-api-kong.cfapps.io
```

## Use Basic Authentication Plugin

### Enable plugin

```
curl -X POST http://localhost:8001/apis/example-api/plugins -d name=basic-auth -d config.hide_credentials=true
```

### Add consumer

```
curl -X POST http://localhost:8001/consumers -d username=demo
```

### Add user

```
curl -X POST http://localhost:8001/consumers/demo/basic-auth -d username=user -d password=password
```

Access example API

```
curl -u user:password https://example-api-kong.cfapps.io
```

