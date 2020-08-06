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
cf ssh -N -T -L 8081:localhost:8081 your-kong-app
```

## Map a route to your service

```bash
~$ cf map-route cf-kong app.cloud.gov -n example-api-kong
```

## Add a service in Kong

```bash
~$ curl -i -X POST http://localhost:8081/services --data name=example_service --data url='https://www.google.com/'


HTTP/1.1 201 Created
Date: Thu, 06 Aug 2020 14:47:18 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Access-Control-Allow-Origin: *
Server: kong/2.1.1
Content-Length: 366
X-Kong-Admin-Latency: 11

{"host":"www.google.com","id":"f9c4a6b3-5abb-4dac-8638-ddb0900b3a33","protocol":"https","read_timeout":60000,"tls_verify_depth":null,"port":443,"updated_at":1596725238,"ca_certificates":null,"created_at":1596725238,"connect_timeout":60000,"write_timeout":60000,"name":"example_service","retries":5,"path":"\/","tls_verify":null,"tags":null,"client_certificate":null}
```

## Verify the service's endpoint:

```bash
~$ curl -i http://localhost:8081/services/example_service

HTTP/1.1 200 OK
Date: Thu, 06 Aug 2020 14:48:15 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Access-Control-Allow-Origin: *
Server: kong/2.1.1
Content-Length: 366
X-Kong-Admin-Latency: 3

{"host":"www.google.com","id":"f9c4a6b3-5abb-4dac-8638-ddb0900b3a33","protocol":"https","read_timeout":60000,"tls_verify_depth":null,"port":443,"updated_at":1596725238,"ca_certificates":null,"created_at":1596725238,"connect_timeout":60000,"write_timeout":60000,"name":"example_service","retries":5,"path":"\/","tls_verify":null,"tags":null,"client_certificate":null}
```

## Add a route

```bash
~$ curl -i -X POST http://localhost:8081/services/example_service/routes --data 'paths[]=/google' --data 'name=google'

HTTP/1.1 201 Created
Date: Thu, 06 Aug 2020 14:49:31 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Access-Control-Allow-Origin: *
Server: kong/2.1.1
Content-Length: 430
X-Kong-Admin-Latency: 12

{"id":"9e9f0d56-7ac9-4341-9481-41c5736e309e","path_handling":"v0","paths":["\/google"],"destinations":null,"headers":null,"protocols":["http","https"],"created_at":1596725371,"snis":null,"service":{"id":"f9c4a6b3-5abb-4dac-8638-ddb0900b3a33"},"name":"google","strip_path":true,"preserve_host":false,"regex_priority":0,"updated_at":1596725371,"sources":null,"methods":null,"https_redirect_status_code":426,"hosts":null,"tags":null}
```

Try opening https://example-api-kong.app.cloud.gov/google in your web browser.