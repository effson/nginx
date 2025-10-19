
# 1. upstream模块的变量(不含cache)

## 1.1 $upstream_addr
> 实际连接的上游服务器地址（可能有多个）,**如127.0.0.1:8080, 127.0.0.1:8081**

## 1.2 $upstream_connect_time
> 建立与上游连接所花的时间（秒），精确到毫秒

## 1.1 $upstream_header_time
> 从发出请求到收到上游响应头的时间（秒），精确到毫秒

## 1.1 $upstream_response_time
> 从请求上游到接收完响应的总时间（秒）

## 1.1 $upstream_http_<header>
> 上游返回的某个 HTTP 响应头

## 1.2 
