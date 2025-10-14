ngx_http_proxy_module 是 Nginx 中用于实现反向代理功能的核心模块，配置项非常丰富。以下是常用参数及其说明：

# 基础转发参数
```
指令	说明
proxy_pass	   指定要代理到的后端服务器地址（必需）
proxy_redirect	           修改后端返回的 Location 和 Refresh 响应头中的 URL
proxy_set_header	      修改传给后端服务器的请求头（如设置 Host）
proxy_http_version	      设置使用的 HTTP 协议版本（如 1.0 / 1.1）
proxy_method	         可改变转发请求的方法（较少使用）

```
# 缓存与连接控制
```
指令	                    说明
proxy_connect_timeout	     连接后端服务器的超时时间
proxy_send_timeout	         向后端发送请求的超时时间
proxy_read_timeout	         等待后端响应的超时时间
proxy_buffering	             是否启用缓冲后端响应（默认开启）
proxy_buffers	             定义缓冲区的数量和大小
proxy_buffer_size	         为响应头分配的单个缓冲区大小
proxy_busy_buffers_size	     忙碌缓冲区的最大总大小
proxy_max_temp_file_size	 响应写入临时文件的最大大小
proxy_temp_file_write_size	 &nbsp;临时文件每次写入的最大数据量
proxy_temp_path	             指定临时文件目录
```
# 请求头与转发细节
```
指令	                     说明<br>
proxy_set_body	             设置传递给后端的请求体
proxy_pass_request_body	     是否将客户端请求体传给后端
proxy_pass_request_headers  	是否传递请求头给后端
proxy_hide_header	         隐藏从后端返回的某些响应头
proxy_ignore_headers	     忽略指定的响应头
proxy_pass_header	         显式地传递某些响应头
proxy_cookie_domain	         修改响应中 Set-Cookie 的域
proxy_cookie_path	         修改响应中 Set-Cookie 的路径
```
# 请求转发行为
```
指令	                     说明<br>
proxy_intercept_errors	     是否拦截后端返回的错误码，允许自定义错误页
proxy_next_upstream	         设置请求失败后是否重试其他上游服务器（如超时/502）
proxy_next_upstream_tries 	 最多重试几次
proxy_next_upstream_timeout	 最长重试时间
<br>
```
# 路径与URI处理
```
指令	                      说明
proxy_pass	                 可以设置成 http://backend（保留 URI）或 http://backend/（去掉匹配部分）
proxy_request_buffering	     是否在发送到后端之前缓冲整个请求

```
# 安全相关
```
指令	                         说明
proxy_ssl_certificate	         客户端证书路径
proxy_ssl_certificate_key	     客户端证书的私钥
proxy_ssl_trusted_certificate 	信任的 CA 证书
proxy_ssl_verify	             是否校验证书
proxy_ssl_verify_depth	         设置验证深度
```
# proxy_cache 模块
功能：<br>
缓存后端服务器的响应内容，提升性能，减少后端压力。<br>
<br>
## 常用配置指令一览
```
指令	                         说明<br>
proxy_cache	                     指定使用哪个缓存区域
proxy_cache_path	             定义缓存目录、大小、key结构等
proxy_cache_key	                设置缓存 key（决定哪些请求会命中缓存）
proxy_cache_valid	             指定不同响应码对应的缓存时间
proxy_cache_methods	            指定哪些方法可以缓存（如 GET、HEAD）
proxy_cache_use_stale	         在后端失败时是否使用过期缓存
proxy_cache_bypass	             指定某些请求不使用缓存（条件变量）
proxy_no_cache	                 指定某些请求不缓存响应（条件变量）
proxy_cache_lock	             启用锁机制避免缓存穿透（多个请求打后端）
proxy_cache_lock_timeout	     锁等待时间
proxy_cache_min_uses	         至少请求几次后才缓存
add_header X-Cache-Status	     添加缓存状态响应头（如 HIT、MISS）
```
## proxy_cache示例配置

### 1. 定义缓存路径
```
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m use_temp_path=off;
```
### 2. 在 server 或 location 中启用缓存<br>
```
location /api/ {
     proxy_pass http://backend;
     <br>
     proxy_cache my_cache;  # 指定缓存区域<br>
     proxy_cache_valid 200 302 10m;   # 只缓存200/302响应，10分钟
     proxy_cache_valid 404 1m;<br>
     proxy_cache_use_stale error timeout updating;
     proxy_cache_lock on;
 
     proxy_cache_key "$scheme$proxy_host$request_uri";
   
     add_header X-Cache-Status $upstream_cache_status;
}
```
### $upstream_cache_status 可取值
```
值 	说明
MISS	           未命中缓存，请求了后端<br>
HIT	           成功命中缓存<br>
BYPASS          被 proxy_cache_bypass 绕过了缓存<br>
EXPIRED	      缓存已过期，请求了后端并刷新<br>
STALE 	      后端失败时使用了旧缓存<br>
UPDATING	      当前缓存正在更新，使用旧内容返回<br>
REVALIDATED	 对已缓存的响应进行验证后仍可使用<br>
```
### 3.配置解释<br>
### location /api/ {<br>
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    proxy_pass http://backend;<br>
 
功能：把客户端对 /api/ 的请求反向代理给名为 backend 的上游服务器（可以是 IP、域名或 upstream 块定义）。<br>
<br>
注意：路径是否保留 /api/ 取决于 proxy_pass 后面有没有斜杠（你这里没有尾部 /，所以会保留 /api/）。<br>
<br>
<br>
###  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   proxy_cache my_cache;<br>

功能：启用缓存功能，使用之前通过 proxy_cache_path 定义的缓存区域 my_cache。<br>

意义：后端响应的数据可以被缓存下来，下次相同请求会直接返回缓存，提高性能，减少后端压力。<br>

 ### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    proxy_cache_valid 200 302 10m;<br>

功能：指定 HTTP 状态码为 200 OK 和 302 Found 的响应缓存时间为 10 分钟。<br>
<br>
用途：控制缓存的生命周期（有效期），缓存过期后会重新请求后端。<br>
<br>

### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    proxy_cache_valid 404 1m;<br>
功能：对于 404 Not Found 的响应，也缓存，但时间仅为 1 分钟。<br>
<br>
用途：避免频繁请求不存在的资源对后端造成压力。<br>
<br>
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    proxy_cache_use_stale error timeout updating;<br>

功能：允许在以下场景使用“过期的缓存内容”作为响应：<br>
<br>
error：后端返回错误（如 500）<br>
<br>
timeout：连接或读取超时<br>
<br>
updating：当前有其他请求正在更新缓存时<br>
<br>
意义：提升系统容错性和高可用性，避免因后端不稳定导致请求失败。<br>
<br>
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    proxy_cache_lock on;<br>

功能：启用缓存锁，防止同一时间多个请求都去打后端，造成“缓存穿透”。<br>
<br>
用途：只有第一个请求会去更新缓存，其他请求等待缓存完成后使用最新内容。<br>
<br>

###  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   proxy_cache_key "$scheme$proxy_host$request_uri";<br>
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   proxy_cache_key<br>
功能：设置缓存的 key（唯一标识缓存条目的标识符）。<br>
<br>
默认值 是 $scheme$proxy_host$request_uri，即：<br>
<br>
http/https（$scheme）<br>
<br>
代理主机名（$proxy_host）<br>
<br>
完整请求路径和查询参数（$request_uri）<br>
<br>
意义：决定了缓存是如何命中的。如果你要对不同参数缓存不同内容，这个设置非常关键。<br>

###  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   add_header X-Cache-Status $upstream_cache_status;<br>

功能：在响应头中添加 X-Cache-Status 字段，用于显示缓存状态。<br>
# 示例配置<br>
```
location /api/ {
     proxy_pass http://127.0.0.1:8080/;
     proxy_set_header Host $host;
     proxy_set_header X-Real-IP $remote_addr;
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_connect_timeout 3s;
     proxy_read_timeout 10s;
     proxy_buffering off;
}
```
