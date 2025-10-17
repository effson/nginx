# 1. Nginx 变量
## 1.1 HTTP请求相关变量
### 1.1.1 $arg_参数名
```pgsql
http://example.com/index.html?id=10&user=jeff&debug=1
```
Nginx 会自动解析 ? 之后的查询字符串：
```ini
id=10
user=jeff
debug=1
```
生成一组变量：
```
变量名	    值
$args	    id=10&user=jeff&debug=1
$arg_id	    10
$arg_user	jeff
$arg_debug	1
```
### 1.1.1 $query_string
户端原始请求行中的查询字符串部分（不含 ?），与$args相同

### 1.1.2 $args
查询字符串部分，即 URL 中 ? 后面的参数，不包括 ? 本身

### 1.1.3 $is_args
? 或 空 , 若存在参数则为 ?，否则为空

### 1.1.4 $content_length
HTTP请求中标识包体长度的Content-Length头部的值

### 1.1.5 $content_type
标识请求包体内容类型的Content-type头部的值

### 1.1.6 $document_uri
与 $uri 相同

### 1.1.7 $uri
当前请求的 URI 路径部分，不包含查询字符串（?后面的参数）

### 1.1.8 $request_uri
客户端原始请求 URI（包含uri和参数）

### 1.1.9 $scheme
协议，http 或 https

### 1.1.10 $request_method
请求方法（GET/POST/PUT/DELETE 等）
示例：
```nginx
if ($request_method = POST) {
    proxy_pass http://backend_post;
}
```

### 1.1.9 $request_length
请求报文总长度（包括请求行、请求头和请求体的总和，单位：字节）

### 1.1.9 $remote_user
HTTP Basic Authentication 协议传入的用户名


















```
在 Nginx 中，HTTP 框架提供了许多请求变量，这些变量可以用来获取有关请求的信息。以下是一些常用的请求变量：
常用请求变量:

🔸 $request

描述：完整的请求行，包括请求方法、URI 和 HTTP 协议版本。
格式：GET /index.html?name=abc HTTP/1.1
用途：常用于日志中记录完整请求内容。
示例：
log_format custom_log '$request';
access_log /var/log/nginx/access.log custom_log;


# 2
```


🔹 $remote_user
含义：经过 HTTP 认证的用户名（仅在配置了如 auth_basic 时有效）。
默认值：如果没有认证信息，则为空。
用途：记录或基于用户名实现访问控制。
示例：
log_format log_user '$remote_user accessed $uri';
access_log /var/log/nginx/access.log log_user;

auth_basic "提示文字";  #设置认证提示文本（显示在浏览器弹窗中）。
auth_basic_user_file /path/to/.htpasswd; # 指定用户密码文件（htpasswd 文件）。


🔹 $request_uri
含义：请求的原始 URI，包含路径和查询字符串（即包括 ? 后面的部分）。
示例：请求 /index.html?page=1
$request_uri = /index.html?page=1
用途：
用于日志记录、重定向原始请求地址等。
示例：
return 302 /new$request_uri;


🔹 $document_uri（或 $uri）
含义：请求的 URI（不含查询字符串部分），也叫 $uri，是解析后的路径。
说明：
$uri 会经过内部重写后再映射资源；
原始路径还保留在 $request_uri 中。
用途：匹配 location，静态文件查找，重写。
示例：
location / {
    root /var/www/html;
    try_files $uri $uri/ =404;
}

🔹 $scheme
含义：客户端请求使用的协议：http 或 https。
用途：
重定向到 HTTPS；
构造完整的 URL。
示例：
if ($scheme = http) {
    return 301 https://$host$request_uri;
}
```

# 3
```
🔸 $remote_addr
含义：客户端的 IP 地址（如 192.168.1.100）
用途：
日志记录访问者
限制访问来源 IP
示例：
if ($remote_addr = 192.168.1.100) {
    return 403;
}

🔸 $request_body_file
含义：当客户端请求体较大时（如上传文件），Nginx 会将其缓存到临时文件中，这个变量表示该文件的路径。
用途：在复杂 POST 或 PUT 请求中获取请求体。
注意：仅在使用 client_body_in_file_only on; 时才会设置。
示例：
client_body_in_file_only on;
access_log /var/log/nginx/post_body.log '$request_body_file';

🔸 $request_body
含义：整个请求体的内容（如 POST 的数据）
用途：常用于调试、记录客户端发送的数据。
注意：不能在 rewrite 阶段使用，推荐只用于 log_format 或下游模块。
示例：
log_format post_body '$remote_addr sent: $request_body';

🔸 $server_name
含义：当前处理请求的 server 块中定义的 server_name（如 example.com）
用途：
多站点识别
日志记录和自定义响应
示例：
log_format vhost '$server_name $request_uri';

🔸 $server_port
含义：服务器监听的端口（如 80 或 443）
用途：
多端口服务判断（比如同一个服务运行在 80 和 8080）
示例：
if ($server_port = 8080) {
    return 403;
}

🔸 $request_time
含义：从接收到客户端请求头到响应完成所消耗的总时间（单位：秒，浮点数）
用途：
性能分析
慢请求监控
示例：
log_format perf_log '[$request_time sec] $request';

🔸 $time_local
含义：当前服务器的本地时间，格式如：24/Jun/2025:23:20:14 +0800
用途：
日志时间戳
格式友好的时间显示
示例：
log_format custom_time '[$time_local] $remote_addr $request';

```

# 4
```
🔸 $host
表示客户端请求中 Host 请求头的值。
如果请求中包含 Host 头（大多数情况都会有），则 $host 就是它的值。
如果请求中没有 Host 头，则 $host 会自动回退为 server_name 中的第一个名字。
如果没有配置 server_name，则会使用监听 IP。
```

# 5
```
🔹 $http_cookie
含义：客户端发送的 Cookie 内容。
用途：
判断用户状态（是否已登录）
记录日志
实现简单的 A/B 测试或流量分流
示例：
if ($http_cookie ~* "user=admin") {
    return 403; # 阻止某个用户
}

🔹 $http_via
含义：如果客户端请求经过了一个或多个代理（如 CDN 或缓存服务器），这些代理通常会在请求中添加 Via 头部。
用途：
判断请求是否经过了中间代理
进行缓存或链路分析
示例：
log_format log_via '$remote_addr via: $http_via';

🔹 $http_host
含义：客户端请求头中的 Host 字段的原始值（即未被解析的）。
✅ 和 $host 的区别：
$http_host 是请求头中 Host: 字段的原始值；
$host 是 $http_host 的标准化版本，并在没有请求头时自动 fallback。
用途：
精确匹配某些非法 Host 请求
示例：
if ($http_host ~* "badhost.com") {
    return 444; # 直接断开连接
}

🔹 $http_user_agent
含义：客户端浏览器或工具的 User-Agent 信息（如 Chrome、curl、微信等）
用途：
日志记录
判断访问来源设备/浏览器
做 UA 白名单/黑名单
示例：
if ($http_user_agent ~* "curl") {
    return 403;  # 阻止命令行工具访问
}

🔹 $http_referer
含义：引荐页面的 URL，即用户是从哪个页面跳转过来的。
用途：
防盗链
广告点击追踪
访问分析
示例：防止图片盗链
location ~* \.(jpg|png|gif)$ {
    valid_referers none blocked *.mydomain.com;
    if ($invalid_referer) {
        return 403;
    }
}

🔹 $http_x_forwarded_for
含义：客户端的原始 IP 地址，由前置代理服务器设置。
常见来源：CDN、Nginx 反向代理、负载均衡器等。
用途：
获取真实客户端 IP（尤其是服务器后面挂了代理时）
注意：
它可能包含多个 IP，用逗号分隔，格式如：
$http_x_forwarded_for = "203.0.113.1, 10.0.0.2, 127.0.0.1"
第一个一般是原始客户端 IP。
示例：
set_real_ip_from 0.0.0.0/0;     # 信任所有代理（仅测试用）
real_ip_header X-Forwarded-For;
```
