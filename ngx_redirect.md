```
server_name_in_redirect、port_in_redirect、absolute_redirect
这三个是 Nginx 中与重定向（redirect）时使用的主机名和端口有关的配置项，常用于控制 301、302 这类重定向响应中的 Location 头字段内容。

它们属于 ngx_http_core_module 模块，影响到当 Nginx 自动或手动生成重定向时，Location URL 中主机名、端口、是否使用绝对路径等行为。

🔧 三个配置指令详解
1. server_name_in_redirect
作用：是否在重定向的 Location 头中使用 server_name（配置文件中的 server_name 值），而不是客户端请求的主机名（Host 头）。

语法：

nginx
复制
编辑
server_name_in_redirect on | off;
默认值：off

适用范围：http, server, location

举例：

nginx
复制
编辑
server {
    listen 80;
    server_name example.com;
    server_name_in_redirect on;
    ...
}
如果你访问的是 http://mydomain.com/foo/，它会重定向到 http://example.com/foo/，因为开启了 server_name_in_redirect。

2. port_in_redirect
作用：控制是否在重定向 URL 的 Location 中显示端口号。

语法：

nginx
复制
编辑
port_in_redirect on | off;
默认值：on

适用范围：http, server, location

说明：

on：总是包含端口号（除非是标准端口，如 80 或 443）；

off：不显示端口号。

示例：

nginx
复制
编辑
server {
    listen 8080;
    port_in_redirect off;
    ...
}
当客户端访问 http://host:8080/foo 时，返回的 Location 重定向可能是 http://host/foo（不含端口）。

3. absolute_redirect
作用：控制是否使用绝对 URI（带 scheme 和 host 的 URL）进行重定向。

语法：

nginx
复制
编辑
absolute_redirect on | off;
默认值：on

适用范围：http, server, location

区别：

设置	返回内容
on	Location: http://example.com/foo/
off	Location: /foo/（相对路径）

用途：在一些特殊反向代理环境（比如 Nginx 本身被反向代理）中，可关闭此项避免出现 Location 带外网不可达的主机名。

🧠 总结对比
指令	控制内容	默认值
server_name_in_redirect	是否使用配置中的 server_name 来生成 Location 中的域名	off
port_in_redirect	是否在 Location 中附加端口号	on
absolute_redirect	是否返回完整的 URL（包括 scheme 和 host）	on
```
