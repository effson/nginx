# 0 概述<br>
Nginx 的 limit_req 是一个用于 限制客户端请求速率（QPS） 的模块，常用于防止：<br>
#### 1.某个接口被刷（防刷接口）<br>
#### 2.某个 IP 过载请求<br>
#### 3.接入层服务被突发请求打挂<br>
limit_req 是由 ngx_http_limit_req_module 模块提供的。<br>
默认编译安装的 Nginx 是带有该模块的<br>
# 1 配置指令总览<br>
limit_req_zone	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;定义限速的 共享内存区域，通常按 IP 分组<br>
limit_req	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;在某个 location 中应用限速规则<br>
limit_req_log_level	&nbsp;&nbsp;&nbsp;&nbsp;控制被限流时的日志级别<br>
limit_req_status	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;被限流时返回的 HTTP 状态码（默认 503）<br>
# 2 示例：限制单个 IP 每秒最多请求 1 次<br>
http {<br>
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




