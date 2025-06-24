# 1
```
在 Nginx 中，HTTP 框架提供了许多请求变量，这些变量可以用来获取有关请求的信息。以下是一些常用的请求变量：

常用请求变量
$request: 整个请求行，包括请求方法、URI 和 HTTP 版本。
$args: 请求中的查询字符串部分。
$query_string:描述: 该变量包含请求的查询字符串部分，即 URL 中 ? 后面的部分
$content_length: 请求体的长度。
$content_type: 请求体的内容类型。
$is_args: 该变量用于指示查询字符串是否存在。如果存在，它的值为 ?，如果不存在，则为空字符串。
```

# 2
```
$request_method: 请求的方法，如 GET、POST 等。
$request_length:
$remote_user:
$request_uri:
$document_uri:
$uri: 请求的 URI（不包括查询字符串,也就是？后面的）。
$scheme: 请求的协议（http 或 https）。
```

# 3
```
$remote_addr: 客户端的 IP 地址。
$request_body_file:
$request_body:
$server_name: 服务器的名称。
$server_port: 服务器的端口号。
$request_time: 处理请求所花费的时间。
$time_local: 当前的本地时间。
这些变量可以在 Nginx 配置文件中使用，尤其是在日志格式、条件判断和重定向中。通过灵活使用这些变量，可以实现更复杂的请求处理逻辑
```

# 4
```
$host
```

# 5
```
$http_cookie: 请求中的 Cookie。
$http_via:
$http_host:
$http_user_agent: 客户端的用户代理字符串。
$http_referer: 引荐页面的 URL。
$http_x_forwarded_for:
```
