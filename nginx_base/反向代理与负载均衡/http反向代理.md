# 1. HTTP反向代理流程
<img width="988" height="526" alt="image" src="https://github.com/user-attachments/assets/1506fe66-3c32-462b-ae8e-7ed613415b0c" />


# 2. proxy模块
**ngx_http_proxy_module** 是 <mark>**HTTP 反向代理模块**</mark>，它在 Nginx 的 CONTENT 阶段 执行，是最常用的 upstream 模块之一。

## 2.1 proxy_pass

### 2.1.1 指令的使用
```nginx
proxy_pass URL;
```
URL:
- **必须是http://或https://开头**
- 直接上游地址：http://127.0.0.1:8080
- upstream 名称：http://backend
- 动态变量：http://$host$request_uri
- 可选的 URI 部分（注意斜杠！）

### 2.1.2 URL参数是否携带URI

#### 携带URI
```nginx
location /api/ {
    proxy_pass http://backend/u1;
}
```
结果：
```
客户端：/api/abc ---> 发往上游：http://backend/u1/abc
客户端：/api/v1/user?id=1 ---> 发往上游：http://backend/u1/v1/user?id=1
```

#### 不携带URI
```nginx
location /api/ {
    proxy_pass http://backend;
}
```
结果：
```
客户端：/api/abc ---> 发往上游：http://backend/api/abc
客户端：/api/v1/user?id=1 ---> 发往上游：http://backend/api/v1/user?id=1
```

## 2.2 proxy模块生成发往上游的请求

### 2.2.1 proxy_method
proxy_method 指令用于 更改 发送到后端（上游）服务器的请求方法（HTTP Method）。
```nginx
proxy_method method;
```

```nginx
location /api {
    proxy_pass http://backend_server;
    # 强制将所有代理到后端的请求方法都改为 GET
    proxy_method GET;
}
```
- 默认行为：如果不设置此指令，Nginx 会默认使用 客户端请求的原始方法 (例如 GET, POST, PUT, DELETE 等) 发送给后端

### 2.2.2 proxy_http_version

```nginx
proxy_http_version 1.0 | 1.1;
```
- 设置 Nginx 在代理请求时，发送给后端（上游）服务器的 HTTP 协议版本。
- 默认值：该指令的默认值是 1.0。

### 2.2.3 proxy_set_header

```nginx
proxy_set_header field value;
```

```nginx
# 将客户端请求的原始 Host 头传递给后端
proxy_set_header Host $host;

# 或者使用 $http_host, 效果类似，但 $host 在没有 Host 头时会使用 server_name
# proxy_set_header Host $http_host;
```

- 设置或修改 Nginx 代理请求时，发送给 后端服务器 的请求头（Request Headers）


### 2.2.4 proxy_pass_request_header

```nginx
proxy_pass_request_headers on | off;
```

- 控制 Nginx 是否将客户端请求头部转发给上游服务器（upstream）
-  on → 正常转发：客户端请求头（如 User-Agent, Accept, Cookie, 等）都会发送给上游；
- off → 不转发：上游请求中不会包含任何客户端请求头，除非你手动用 proxy_set_header 添加。












