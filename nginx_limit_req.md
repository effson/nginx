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
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;            limit_req zone=one burst=5 nodelay;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;           proxy_pass http://backend;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        }<br>
&nbsp;&nbsp;&nbsp;&nbsp;    }<br>
}<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
