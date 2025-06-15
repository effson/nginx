# 0 rewrite概述
在 Nginx 的请求处理流程中，**rewrite 阶段（重写阶段）**是非常重要的一环。它主要用于：<br>

修改请求的 URI（统一资源标识符）<br>

进行内部重定向<br>
<br>
控制访问流程（比如结合 return、break、rewrite 指令）<br>
# 1rewrite 阶段做什么<br>
# 1.1. 修改 URI<br>
<br>
location /old {<br>
    rewrite ^/old/(.*)$ /new/$1 break;<br>
}
这个规则将 /old/foo 改写为 /new/foo。<br>
<br>
2. 内部跳转（internal redirect）<br>
使用 rewrite 后可以跳转到新的 URI，重新走一次 location 匹配。<br>
<br>
rewrite ^/foo$ /bar;<br>
这会让请求 /foo 变为 /bar，重新匹配 location。<br>
<br>
3. 结合 break/last/redirect/permanent<br>
break：停止 rewrite 阶段，继续在当前 location 内执行后续处理。<br>
<br>
last：重新走一次 location 匹配。<br>
<br>
redirect：返回 302。<br>
<br>
permanent：返回 301。<br>
<br>
三、rewrite 指令生效位置<br>
只能出现在：<br>
<br>
server 块中<br>

location 块中<br>

if 块中<br>

不能出现在 http 块中。<br>
<br>
四、示例说明<br>

server {<br>
    listen 80;<br>
    server_name example.com;<br>
<br>
    location / {<br>
        rewrite ^/foo/(.*)$ /bar/$1 break;<br>
        proxy_pass http://backend;<br>
    }<br>
<br>
    location /bar {<br>
        return 200 'Hello from /bar!';<br>
    }<br>
}<br>
访问 http://example.com/foo/test 时：<br>
<br>
URI 被 rewrite 改成 /bar/test<br>
<br>
rewrite 使用 break，不重新匹配 location<br>
<br>
最终仍在 / 匹配中，转发给后端<br>
<br>
五、rewrite模块和阶段的关系<br>
Nginx 的 ngx_http_rewrite_module 模块是在 rewrite 阶段工作的，它注册了 NGX_HTTP_REWRITE_PHASE 的 handler。<br>
<br>
这个阶段执行顺序早于 access 阶段，也早于 content 阶段，因此非常适合做前置处理。<br>
<br>
六、rewrite 阶段常见用途<br>
URL 伪静态（SEO）<br>
<br>
跳转旧接口路径到新路径<br>
<br>
基于条件的请求重写（如 UA 检测、IP 匹配等）<br>
