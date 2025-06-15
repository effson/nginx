# 0 概述<br>
limit_conn 是 Nginx 中用于限制并发连接数的指令，它配合 limit_conn_zone 使用，属于 ngx_http_limit_conn_module。<br>
limit_conn 用于限制某个“key”（如 IP）对应的活动连接数，例如限制每个客户端 IP 最多同时建立 1 个连接。<br>

# 1 基本语法limit_conn_zone<br>
## 1.1 简介
#### Nginx中用于连接数限制（concurrent connections）的配置指令，
#### 属于 ngx_http_limit_conn_module 模块<br>
#### 限制单个客户端 IP 的连接数（防止慢连接攻击）<br>
#### 限制某类用户、域名、接口的并发连接数<br>
## 1.2 基本语法<br>
### limit_conn_zone key zone=name:size; <br>
#### key：限制的单位，如 $binary_remote_addr（客户端 IP）<br>
#### zone=name:size：共享内存区的名字和大小，例如 zone=addr:10m <br>
#### ⚠️ 注意：这个指令 只能放在 http 块中<br>
## 1.3 示例：限制每个 IP 同时最多 1 个连接<br>
http {<br>
&nbsp;&nbsp;&nbsp;&nbsp;    # 创建一个共享内存区域 addr，每个 IP 限制连接数<br>
&nbsp;&nbsp;&nbsp;&nbsp;    limit_conn_zone $binary_remote_addr zone=addr:10m;<br>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;   server {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        listen 80;<br>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        location / {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        # 应用上面的区域，每个 IP 最多 1 个连接<br>
            limit_conn addr 1;<br>
        }<br>
    }<br>
}<br>
<br>

&nbsp;&nbsp;&nbsp;&nbsp;    # 定义名为 'one' 的限流区域，按 $binary_remote_addr（IP地址）分组，最大存储1万条记录<br>
&nbsp;&nbsp;&nbsp;&nbsp;    limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;<br>

&nbsp;&nbsp;&nbsp;&nbsp;    server {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        listen 80;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        server_name localhost;<br>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;       location /api/ {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;            limit_req zone=one burst=5 nodelay;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;           proxy_pass http://backend;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        }<br>
&nbsp;&nbsp;&nbsp;&nbsp;    }<br>
}<br>
# 3 参数解释<br>
## 3.1 limit_req_zone<br>
### limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;<br>
#### $binary_remote_addr：表示按客户端 IP 限制<br>
#### zone=one:10m：创建一个名为 one、大小为 10MB 的共享内存区<br>
#### rate=1r/s：表示平均每秒只允许一个请求（Rate Limit）<br>
## 3.2 limit_req<br>
### limit_req zone=one burst=5 nodelay;<br>
#### zone=one：应用哪个 zone（对应前面的定义）<br>
#### burst=5：允许突发最多 5 个请求（类似令牌桶）<br>
#### nodelay：<br>
有：只要在 burst 之内，就立即处理（适合低延迟接口）<br>
无：超出的请求将会排队延迟处理（更公平）<br>
## 3.3 其他可选指令<br>
### limit_req_log_level warn;<br>
### limit_req_status 429;<br>
#### log_level：限制生效时的日志等级（默认为 error）<br>
#### status：限制生效时的 HTTP 状态码，默认 503，可自定义为 429（更合理）<br>
