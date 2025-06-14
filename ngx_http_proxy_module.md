ngx_http_proxy_module 是 Nginx 中用于实现反向代理功能的核心模块，配置项非常丰富。以下是常用参数及其说明：

# 基础转发参数<br>
指令	说明<br>
proxy_pass	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   指定要代理到的后端服务器地址（必需）<br>
proxy_redirect	   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;         修改后端返回的 Location 和 Refresh 响应头中的 URL<br>
proxy_set_header	      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;修改传给后端服务器的请求头（如设置 Host）<br>
proxy_http_version	       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  设置使用的 HTTP 协议版本（如 1.0 / 1.1）<br>
proxy_method	         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    可改变转发请求的方法（较少使用）<br>
<br>
# 缓存与连接控制<br>
指令	                    说明<br>
proxy_connect_timeout	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   连接后端服务器的超时时间<br>
proxy_send_timeout	     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    向后端发送请求的超时时间<br>
proxy_read_timeout	    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;     等待后端响应的超时时间<br>
proxy_buffering	          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   是否启用缓冲后端响应（默认开启）<br>
proxy_buffers	          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   定义缓冲区的数量和大小<br>
proxy_buffer_size	       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  为响应头分配的单个缓冲区大小<br>
proxy_busy_buffers_size	   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  忙碌缓冲区的最大总大小<br>
proxy_max_temp_file_size	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;响应写入临时文件的最大大小<br>
proxy_temp_file_write_size	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;临时文件每次写入的最大数据量<br>
proxy_temp_path	         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    指定临时文件目录<br>

# 请求头与转发细节<br>
指令	             &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        说明<br>
proxy_set_body	       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;      设置传递给后端的请求体<br>
proxy_pass_request_body	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   是否将客户端请求体传给后端<br>
proxy_pass_request_headers &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	是否传递请求头给后端<br>
proxy_hide_header	     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    隐藏从后端返回的某些响应头<br>
proxy_ignore_headers	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    忽略指定的响应头<br>
proxy_pass_header	    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;     显式地传递某些响应头<br>
proxy_cookie_domain	    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;     修改响应中 Set-Cookie 的域<br>
proxy_cookie_path	   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;      修改响应中 Set-Cookie 的路径<br>

# 请求转发行为<br>
指令	                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    说明<br>
proxy_intercept_errors	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   是否拦截后端返回的错误码，允许自定义错误页<br>
proxy_next_upstream	      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   设置请求失败后是否重试其他上游服务器（如超时/502）<br>
proxy_next_upstream_tries &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	最多重试几次<br>
proxy_next_upstream_timeout	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;最长重试时间<br>
<br>
# 路径与URI处理<br>
指令	           &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;     说明<br>
proxy_pass	          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;       可以设置成 http://backend（保留 URI）或 http://backend/（去掉匹配部分）<br>
proxy_request_buffering	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   是否在发送到后端之前缓冲整个请求<br>
<br>
# 安全相关<br>
指令	               &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;          说明<br>
proxy_ssl_certificate	   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;      客户端证书路径<br>
proxy_ssl_certificate_key	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    客户端证书的私钥<br>
proxy_ssl_trusted_certificate &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	信任的 CA 证书<br>
proxy_ssl_verify	    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;         是否校验证书<br>
proxy_ssl_verify_depth	   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;      设置验证深度<br>
<br> 
<br>
# proxy_cache 模块<br>
功能：<br>
缓存后端服务器的响应内容，提升性能，减少后端压力。<br>
<br>
## 常用配置指令一览<br>
指令	         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;                说明<br>
proxy_cache	         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;            指定使用哪个缓存区域<br>
proxy_cache_path	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;           定义缓存目录、大小、key结构等<br>
proxy_cache_key	     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;            设置缓存 key（决定哪些请求会命中缓存）<br>
proxy_cache_valid	   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;          指定不同响应码对应的缓存时间<br>
proxy_cache_methods	   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;          指定哪些方法可以缓存（如 GET、HEAD）<br>
proxy_cache_use_stale	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        在后端失败时是否使用过期缓存<br>
proxy_cache_bypass	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;           指定某些请求不使用缓存（条件变量）<br>
proxy_no_cache	   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;              指定某些请求不缓存响应（条件变量）<br>
proxy_cache_lock	   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;          启用锁机制避免缓存穿透（多个请求打后端）<br>
proxy_cache_lock_timeout	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    锁等待时间<br>
proxy_cache_min_uses	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        至少请求几次后才缓存<br>
add_header X-Cache-Status	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    添加缓存状态响应头（如 HIT、MISS）<br>
<br>
## proxy_cache示例配置<br>

### 1. 定义缓存路径<br>
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m use_temp_path=off;<br>
<br>
### 2. 在 server 或 location 中启用缓存<br>
location /api/ {<br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   proxy_pass http://backend;<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  proxy_cache my_cache;  # 指定缓存区域<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  proxy_cache_valid 200 302 10m;   # 只缓存200/302响应，10分钟<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  proxy_cache_valid 404 1m;<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  proxy_cache_use_stale error timeout updating;<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  proxy_cache_lock on;<br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   proxy_cache_key "$scheme$proxy_host$request_uri";<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  add_header X-Cache-Status $upstream_cache_status;<br>
}<br>
### $upstream_cache_status 可取值<br>
值 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	说明<br>
MISS	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;未命中缓存，请求了后端<br>
HIT	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;成功命中缓存<br>
BYPASS &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	被 proxy_cache_bypass 绕过了缓存<br>
EXPIRED	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;缓存已过期，请求了后端并刷新<br>
STALE &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	后端失败时使用了旧缓存<br>
UPDATING	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;当前缓存正在更新，使用旧内容返回<br>
REVALIDATED	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;对已缓存的响应进行验证后仍可使用<br>
<br>
### 3.配置解释<br>
location /api/ {<br>
    proxy_pass http://backend;<br>
 proxy_pass http://backend;<br>
功能：把客户端对 /api/ 的请求反向代理给名为 backend 的上游服务器（可以是 IP、域名或 upstream 块定义）。<br>
<br>
注意：路径是否保留 /api/ 取决于 proxy_pass 后面有没有斜杠（你这里没有尾部 /，所以会保留 /api/）。<br>
<br>
<br>
    proxy_cache my_cache;<br>
 proxy_cache my_cache;<br>
功能：启用缓存功能，使用之前通过 proxy_cache_path 定义的缓存区域 my_cache。<br>

意义：后端响应的数据可以被缓存下来，下次相同请求会直接返回缓存，提高性能，减少后端压力。<br>

    proxy_cache_valid 200 302 10m;<br>
   proxy_cache_valid 200 302 10m;<br>
功能：指定 HTTP 状态码为 200 OK 和 302 Found 的响应缓存时间为 10 分钟。<br>
<br>
用途：控制缓存的生命周期（有效期），缓存过期后会重新请求后端。<br>
<br>

    proxy_cache_valid 404 1m;<br>
功能：对于 404 Not Found 的响应，也缓存，但时间仅为 1 分钟。<br>
<br>
用途：避免频繁请求不存在的资源对后端造成压力。<br>
<br>
    proxy_cache_use_stale error timeout updating;<br>
🔁 proxy_cache_use_stale<br>
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
    proxy_cache_lock on;<br>
🔒 proxy_cache_lock on;<br>
功能：启用缓存锁，防止同一时间多个请求都去打后端，造成“缓存穿透”。<br>
<br>
用途：只有第一个请求会去更新缓存，其他请求等待缓存完成后使用最新内容。<br>
<br>

    proxy_cache_key "$scheme$proxy_host$request_uri";<br>
   proxy_cache_key<br>
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

    add_header X-Cache-Status $upstream_cache_status;<br>
🧾 add_header X-Cache-Status $upstream_cache_status;<br>
功能：在响应头中添加 X-Cache-Status 字段，用于显示缓存状态。<br>
# 示例配置<br>
<br>
<br>
location /api/ {<br>
 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    proxy_pass http://127.0.0.1:8080/;<br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   proxy_set_header Host $host;<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  proxy_set_header X-Real-IP $remote_addr;<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;<br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; proxy_connect_timeout 3s;<br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; proxy_read_timeout 10s;<br>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  proxy_buffering off;<br>
}<br>
