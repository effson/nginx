ngx_http_proxy_module 是 Nginx 中用于实现反向代理功能的核心模块，配置项非常丰富。以下是常用参数及其说明：

# 🌐 基础转发参数<br>
指令	说明<br>
proxy_pass	指定要代理到的后端服务器地址（必需）<br>
proxy_redirect	修改后端返回的 Location 和 Refresh 响应头中的 URL<br>
proxy_set_header	修改传给后端服务器的请求头（如设置 Host）<br>
proxy_http_version	设置使用的 HTTP 协议版本（如 1.0 / 1.1）<br>
proxy_method	可改变转发请求的方法（较少使用）<br>
<br>
# 📦 缓存与连接控制<br>
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

# 🧠 请求头与转发细节<br>
指令	说明<br>
proxy_set_body	设置传递给后端的请求体<br>
proxy_pass_request_body	是否将客户端请求体传给后端<br>
proxy_pass_request_headers	是否传递请求头给后端<br>
proxy_hide_header	隐藏从后端返回的某些响应头<br>
proxy_ignore_headers	忽略指定的响应头<br>
proxy_pass_header	显式地传递某些响应头<br>
proxy_cookie_domain	修改响应中 Set-Cookie 的域<br>
proxy_cookie_path	修改响应中 Set-Cookie 的路径<br>

# 📜 请求转发行为<br>
指令	说明<br>
proxy_intercept_errors	是否拦截后端返回的错误码，允许自定义错误页<br>
proxy_next_upstream	设置请求失败后是否重试其他上游服务器（如超时/502）<br>
proxy_next_upstream_tries	最多重试几次<br>
proxy_next_upstream_timeout	最长重试时间<br>
<br>
🛠 路径与URI处理<br>
指令	说明<br>
proxy_pass	可以设置成 http://backend（保留 URI）或 http://backend/（去掉匹配部分）<br>
proxy_request_buffering	是否在发送到后端之前缓冲整个请求<br>
<br>
# 🔐 安全相关<br>
指令	说明<br>
proxy_ssl_certificate	客户端证书路径<br>
proxy_ssl_certificate_key	客户端证书的私钥<br>
proxy_ssl_trusted_certificate	信任的 CA 证书<br>
proxy_ssl_verify	是否校验证书<br>
proxy_ssl_verify_depth	设置验证深度<br>
<br>
# 📍 示例配置<br>
nginx<br>
<br>

location /api/ {
    proxy_pass http://127.0.0.1:8080/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_connect_timeout 3s;
    proxy_read_timeout 10s;
    proxy_buffering off;
}
