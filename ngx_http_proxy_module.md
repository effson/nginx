ngx_http_proxy_module 是 Nginx 中用于实现反向代理功能的核心模块，配置项非常丰富。以下是常用参数及其说明：

# 基础转发参数<br>
指令	说明<br>
proxy_pass	指定要代理到的后端服务器地址（必需）<br>
proxy_redirect	修改后端返回的 Location 和 Refresh 响应头中的 URL<br>
proxy_set_header	修改传给后端服务器的请求头（如设置 Host）<br>
proxy_http_version	设置使用的 HTTP 协议版本（如 1.0 / 1.1）<br>
proxy_method	可改变转发请求的方法（较少使用）<br>
<br>
# 缓存与连接控制<br>
指令	说明<br>
proxy_connect_timeout	连接后端服务器的超时时间<br>
proxy_send_timeout	向后端发送请求的超时时间<br>
proxy_read_timeout	等待后端响应的超时时间<br>
proxy_buffering	是否启用缓冲后端响应（默认开启）<br>
proxy_buffers	定义缓冲区的数量和大小<br>
proxy_buffer_size	为响应头分配的单个缓冲区大小<br>
proxy_busy_buffers_size	忙碌缓冲区的最大总大小<br>
proxy_max_temp_file_size	响应写入临时文件的最大大小<br>
proxy_temp_file_write_size	临时文件每次写入的最大数据量<br>
proxy_temp_path	指定临时文件目录<br>

# 请求头与转发细节<br>
指令	说明<br>
proxy_set_body	设置传递给后端的请求体<br>
proxy_pass_request_body	是否将客户端请求体传给后端<br>
proxy_pass_request_headers	是否传递请求头给后端<br>
proxy_hide_header	隐藏从后端返回的某些响应头<br>
proxy_ignore_headers	忽略指定的响应头<br>
proxy_pass_header	显式地传递某些响应头<br>
proxy_cookie_domain	修改响应中 Set-Cookie 的域<br>
proxy_cookie_path	修改响应中 Set-Cookie 的路径<br>

# 请求转发行为<br>
指令	说明<br>
proxy_intercept_errors	是否拦截后端返回的错误码，允许自定义错误页<br>
proxy_next_upstream	设置请求失败后是否重试其他上游服务器（如超时/502）<br>
proxy_next_upstream_tries	最多重试几次<br>
proxy_next_upstream_timeout	最长重试时间<br>
<br>
# 路径与URI处理<br>
指令	说明<br>
proxy_pass	可以设置成 http://backend（保留 URI）或 http://backend/（去掉匹配部分）<br>
proxy_request_buffering	是否在发送到后端之前缓冲整个请求<br>
<br>
# 安全相关<br>
指令	说明<br>
proxy_ssl_certificate	客户端证书路径<br>
proxy_ssl_certificate_key	客户端证书的私钥<br>
proxy_ssl_trusted_certificate	信任的 CA 证书<br>
proxy_ssl_verify	是否校验证书<br>
proxy_ssl_verify_depth	设置验证深度<br>
<br>
<br>
# proxy_cache 模块<br>
功能：<br>
缓存后端服务器的响应内容，提升性能，减少后端压力。<br>
<br>
## 常用配置指令一览<br>
指令	说明<br>
proxy_cache	指定使用哪个缓存区域<br>
proxy_cache_path	定义缓存目录、大小、key结构等<br>
proxy_cache_key	设置缓存 key（决定哪些请求会命中缓存）<br>
proxy_cache_valid	指定不同响应码对应的缓存时间<br>
proxy_cache_methods	指定哪些方法可以缓存（如 GET、HEAD）<br>
proxy_cache_use_stale	在后端失败时是否使用过期缓存<br>
proxy_cache_bypass	指定某些请求不使用缓存（条件变量）<br>
proxy_no_cache	指定某些请求不缓存响应（条件变量）<br>
proxy_cache_lock	启用锁机制避免缓存穿透（多个请求打后端）<br>
proxy_cache_lock_timeout	锁等待时间<br>
proxy_cache_min_uses	至少请求几次后才缓存<br>
add_header X-Cache-Status	添加缓存状态响应头（如 HIT、MISS）<br>
<br>
## 示例配置<br>

### 1. 定义缓存路径<br>
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m use_temp_path=off;<br>
<br>
### 2. 在 server 或 location 中启用缓存<br>
location /api/ {<br>
    proxy_pass http://backend;<br>
    <br>
    proxy_cache my_cache;  # 指定缓存区域<br>
    proxy_cache_valid 200 302 10m;   # 只缓存200/302响应，10分钟<br>
    proxy_cache_valid 404 1m;<br>
    proxy_cache_use_stale error timeout updating;<br>
    proxy_cache_lock on;<br>
    <br>
    proxy_cache_key "$scheme$proxy_host$request_uri";<br>
    <br>
    add_header X-Cache-Status $upstream_cache_status;<br>
}<br>
### $upstream_cache_status 可取值<br>
值	说明<br>
MISS	未命中缓存，请求了后端<br>
HIT	成功命中缓存<br>
BYPASS	被 proxy_cache_bypass 绕过了缓存<br>
EXPIRED	缓存已过期，请求了后端并刷新<br>
STALE	后端失败时使用了旧缓存<br>
UPDATING	当前缓存正在更新，使用旧内容返回<br>
REVALIDATED	对已缓存的响应进行验证后仍可使用<br>
<br>
### 示例配置<br>
<br>
<br>
location /api/ {<br>
    proxy_pass http://127.0.0.1:8080/;<br>
    proxy_set_header Host $host;<br>
    proxy_set_header X-Real-IP $remote_addr;<br>
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;<br>
    proxy_connect_timeout 3s;<br>
    proxy_read_timeout 10s;<br>
    proxy_buffering off;<br>
}<br>
