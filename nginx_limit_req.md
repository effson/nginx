# 0 概述<br>
Nginx 的 limit_req 是一个用于 限制客户端请求速率（QPS） 的模块，常用于防止：<br>
#### 1.某个接口被刷（防刷接口）<br>
#### 2.某个 IP 过载请求<br>
#### 3.接入层服务被突发请求打挂<br>
limit_req 是由 ngx_http_limit_req_module 模块提供的。<br>
默认编译安装的 Nginx 是带有该模块的<br>
# 1 配置指令总览<br>
limit_req_zone	定义限速的 共享内存区域，通常按 IP 分组<br>
limit_req	在某个 location 中应用限速规则<br>
limit_req_log_level	控制被限流时的日志级别<br>
limit_req_status	被限流时返回的 HTTP 状态码（默认 503）<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
